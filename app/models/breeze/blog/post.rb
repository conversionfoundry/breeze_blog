module Breeze
  module Blog
    class Post
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      include Breeze::Content::Mixins::Permalinks
      include Breeze::Content::Mixins::Markdown
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      
      field :title
      field :slug
      field :body, :markdown => true
      field :published_at, :type => Time
      
      validates_presence_of :title, :slug, :body
      validates_presence_of :author_id, :message => "must be selected"
      
      scope :published, lambda { where(:published_at.lt => Time.now.utc) }
      
      def summary
        # TODO: automatically create summaries, but allow manual customisation.
        body
      end
      
      # Regardless of the published state of the post,
      # returns a date suitable for public display.
      def time
        published_at || created_at
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
    end
  end
end