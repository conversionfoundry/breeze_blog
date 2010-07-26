module Breeze
  module Blog
    class Post
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      identity :type => String

      include Breeze::Content::Mixins::Permalinks
      include Breeze::Content::Mixins::Markdown
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      has_many_related :comments, :class_name => "Breeze::Blog::Comment" do
        def public
          @parent.comments.published.ascending(:created_at)
        end
        
        def build(params = {})
          returning super do |new_comment|
            new_comment.blog_id = @parent.blog_id
          end
        end
      end
      has_many_related :categories, :class_name => "Breeze::Blog::Category", :stored_as => :array
      
      field :title
      field :slug
      field :body, :markdown => true
      field :intro
      field :published_at, :type => Time
      field :comments_count, :type => Integer, :default => 0
      
      validates_presence_of :title, :slug, :body
      validates_presence_of :author_id, :message => "must be selected"

      before_destroy :destroy_children
      
      scope :published, lambda { where(:published_at.lt => Time.now.utc) }
      scope :pending,   lambda { where(:published_at.gt => Time.now.utc) }
      scope :draft,     where(:published_at => nil)
      
      def summary
        # TODO: automatically create summaries, but allow manual customisation.
        body
      end
      
      # Regardless of the published state of the post,
      # returns a date suitable for public display.
      def time
        published_at || created_at
      end
      
      def published?
        published_at.present? && published_at <= DateTime.now
      end
           
      def pending?
        published_at.present? && published_at > DateTime.now
      end
      
      def status
        published? ? :published : :draft
      end
      
      def accepts_comments?
        published?
      end
      
      def commenters
        @commenters ||= comments.only(:name, :id, :created_at).descending(:created_at).all.map do |c|
          { :name => c.name, :id => c.id, :created_at => c.created_at }
        end
      end

      def category_ids=(values)
        write_attribute :category_ids, Array(values).reject(&:blank?)
      end
      
    protected
      def regenerate_permalink!
        self.permalink = "#{blog.permalink}#{date_part}/#{slug}" unless blog.nil? || slug.blank?
      end
      
      def date_part
        if published_at?
          published_at.strftime "/%Y/%m/%d"
        else
          "/unpublished"
        end
      end

      def destroy_children
        comments.map(&:destroy)
      end
      
    end
  end
end