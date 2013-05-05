module Breeze
  module Blog
    class Category
      include Mongoid::Document
      identity :type => String
      
      field :name
      field :position, :type => Integer
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :categories
      include Breeze::Content::Mixins::Permalinks
      
      validates_presence_of :name, :slug
      validates_uniqueness_of :name, :slug, :scope => :blog_id
      before_validation :fill_in_slug
      after_destroy :remove_from_posts
      
      def to_s; name; end
      
      def regenerate_permalink!
        self.permalink = "#{blog.permalink}/categories/#{slug}"
      end
      
      def posts
        blog.posts.published.where :category_ids => id
      end
      
    protected
      def fill_in_slug
        if self.slug.blank? && self.name.present?
          self.slug = self.name.parameterize
          regenerate_permalink!
        end
      end
      
      def remove_from_posts
        Post.collection.update({ :blog_id => blog_id }, { "$pull" => { :category_ids => id } }, :multi => true)
      end
    end
  end
end
