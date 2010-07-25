module Breeze
  module Blog
    class Comment
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      identity :type => String

      include Breeze::Content::Mixins::Markdown
      extend ActiveSupport::Memoizable
      
      field :name
      field :email
      field :website
      field :body, :markdown => true # TODO: sanitize!
      field :status, :default => "pending"
      field :replies_count, :type => Integer, :default => 0
      belongs_to_related :blog,   :class_name => "Breeze::Blog::Blog"
      belongs_to_related :parent, :class_name => "Breeze::Blog::Comment"
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      belongs_to_related :post,   :class_name => "Breeze::Blog::Post"
      
      validates_presence_of :name, :body
      validates_format_of :email, :with => Devise.email_regexp, :message => "must be a valid email address"
      
      before_validation :fill_in_author_details
      before_save :auto_approve
      before_save :update_post_comments_count
      before_destroy :destroy_children
      before_destroy :decrement_post_comments_count, :if => :published?
      before_save :increment_parent_replies_count
      before_destroy :decrement_parent_replies_count
      after_create do |comment|
        Breeze.queue comment, :submit_for_approval
      end
      
      scope :root, where(:parent_id => nil)
      scope :replies_to, lambda { |comment| where(:parent_id => comment.id) }
      scope :awaiting_reply, where(:status => "published", :author_id => nil, :replies_count => 0).ascending(:created_at)

      def root?
        parent_id.nil?
      end

      def status
        read_attribute(:status).try(:to_sym) || :pending
      end

      STATES = %w(published pending spam).freeze unless defined?(STATES)

      STATES.each do |s|
        scope s.to_sym, where(:status => s)
        
        define_method :"#{s}?" do                 # def published?
          status == s.to_sym                      #   status == :published
        end                                       # end

        define_method :"#{s.sub(/ed$/, "")}!" do  # def publish!
          update_attributes :status => s          #   update_attributes :status => "published"
        end                                       # end
        
        define_method :"was_#{s}?" do
          status_changed? && status_was.to_sym == s.to_sym
        end
      end
      
      def authenticated?
        author_id?
      end
      
      def authenticated(user)
        self.name, self.email = user.name, user.email
        self
      end

      def reply_to?(another)
        parent_id == another.id
      end

      def self.reply_to(comment, params = {})
        comment.blog.comments.build params.reverse_merge(
          :post_id   => comment.post_id,
          :parent_id => comment.id,
          :body      => "@#{comment.name}\n\n"
        )
      end
      
      def with_author(author)
        self.author, self.author_id = author, author.id
        self.name, self.email = author.name, author.email
        self
      end
      
      def linked_body
        return body unless body =~ /\@/
        commenters = post.commenters.select { |h| h[:created_at] < created_at }
        @linked = body.gsub(/\@([\w ]+)/) do |link|
          match = commenters.detect { |h| link.starts_with?("@" + h[:name]) }
          if match
            link.sub /^\@#{Regexp.escape(match[:name])}/, %Q{<a href="#comment_#{match[:id]}" class="in-reply-to">@#{match[:name]}</a>}
          else
            "@#{link}"
          end
        end
      end
      memoize :linked_body
      
      def gravatar(options = {})
        options[:size] ||= 64
        "http#{"s" if options[:secure]}://www.gravatar.com/avatar/#{gravatar_hash}?" + options.map { |k, v| "#{k.to_s[0,1]}=#{CGI.escape(v.to_s)}" }.join("&")
      end
      
    protected
      def fill_in_author_details
        if author
          self.name = self.author.name if self.author.blank?
          self.email = self.author.email if self.email.blank?
        end
      end
      
      def auto_approve
        self.status = "published" if author_id || author
      end
    
      def gravatar_hash
        @gravatar_hash ||= Digest::MD5.hexdigest email.downcase.strip
      end
      
      def update_post_comments_count
        if published? && (was_pending? || was_spam?)
          increment_post_comments_count
        elsif was_published?
          decrement_post_comments_count
        end
      end

      def increment_post_comments_count(by = 1)
        post.update_attributes :comments_count => (post.comments_count || 0) + by
      end
      
      def decrement_post_comments_count
        increment_post_comments_count -1
      end

      def increment_parent_replies_count(by = 1)
        parent.update_attributes :replies_count => (parent.replies_count || 0) + by if parent
      end
      
      def decrement_parent_replies_count
        increment_parent_replies_count -1
      end
      
      def destroy_children
        blog.comments.replies_to(self).map(&:destroy)
      end
      
      def submit_for_approval
        blog.comment_strategy.submit self
      end
    end
  end
end