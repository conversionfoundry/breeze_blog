module Breeze
  module Blog
    class CategoryView < IndexView
      attr_accessor :permalink
      
      def set_url_params(permalink)
        super
        self.permalink = permalink
      end
            
      def category
        @category ||= blog.categories.where(:permalink => permalink).first
      end
      
      def posts
        require 'pry'
        binding.pry
        super.where :category_id => category.try(:id)
      end
      
      def variables_for_render
        returning super do |vars|
          vars[:category] = category
        end
      end
    end
  end
end
