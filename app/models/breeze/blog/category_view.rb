module Breeze
  module Blog
    class CategoryView < IndexView
      attr_accessor :category_slug
      
      def set_url_params(match)
        super
        self.category_slug = match[10]
      end
            
      def category
        @category ||= blog.categories.where(:slug => category_slug).first
      end
      
      def posts
        super.where :category_ids => category.try(:id)
      end
      
      def variables_for_render
        returning super do |vars|
          vars[:category] = category
        end
      end
    end
  end
end