module Breeze
  module Blog
    class Category
      unloadable
      
      include Mongoid::Document
      identity :type => String
      
      field :name
      field :position, :type => Integer
      field :posts_count, :type => Integer, :default => 0
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :categories
      include Breeze::Content::Mixins::Permalinks
      
      validates_presence_of :name, :slug
      validates_uniqueness_of :name, :slug
      before_validation :fill_in_slug
      
      def to_s; name; end
      
      def regenerate_permalink!
        self.permalink = "#{blog.permalink}/category/#{slug}"
      end
      
    protected
      def fill_in_slug
        if self.slug.blank? && self.name.present?
          self.slug = self.name.parameterize
          regenerate_permalink!
        end
      end
    end
  end
end