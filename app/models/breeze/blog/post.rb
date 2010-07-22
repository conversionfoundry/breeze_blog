module Breeze
  module Blog
    class Post
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      
      field :title
      field :slug
      field :body
      field :intro
      field :published_at, :type => Time
      
      validates_presence_of :title, :slug, :body
      validates_presence_of :author_id, :message => "must be selected"
      
      scope :published, lambda { where(:published_at.lte => Time.now.utc) }
      scope :pending,   lambda { where(:published_at.gt => Time.now.utc) }
      scope :draft,     lambda { where(:published_at => nil) }

      def published?
        published_at.present? && published_at <= DateTime.now
      end
           
      def pending?
        published_at.present? && published_at > DateTime.now
      end
      
      def status
        published? ? :published : :draft
      end

    end
  end
end