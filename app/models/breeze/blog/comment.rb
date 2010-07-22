module Breeze
  module Blog
    class Comment
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      include Breeze::Content::Mixins::Markdown
      extend ActiveSupport::Memoizable
      
      field :name
      field :email
      field :website
      field :body, :markdown => true # TODO: sanitize!
      field :status, :default => "pending"
      belongs_to_related :blog,   :class_name => "Breeze::Blog::Blog"
      belongs_to_related :parent, :class_name => "Breeze::Blog::Comment"
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      belongs_to_related :post,   :class_name => "Breeze::Blog::Post"
      
      validates_presence_of :name, :body
      validates_format_of :email, :with => Devise.email_regexp, :message => "must be a valid email address"
      
      before_destroy :destroy_children
      
      scope :root, where(:parent_id => nil)
      scope :replies_to, lambda { |comment| where(:parent_id => comment.id) }

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

      def self.reply_to(comment)
        comment.blog.comments.build(
          :post_id   => comment.post_id,
          :parent_id => comment.id
        )
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
      def gravatar_hash
        @gravatar_hash ||= Digest::MD5.hexdigest email.downcase.strip
      end
      
      def destroy_children
        blog.comments.replies_to(self).map(&:destroy)
      end
    end
  end
end