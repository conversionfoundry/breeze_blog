module Breeze
  module Blog
    class PostView < ArchiveView
      unloadable
      
      attr_accessor :slug
      
      def set_url_params(match)
        super
        self.slug = match[9]
      end
      
      def posts
        super.where(:slug => slug)
      end
      
      def post
        posts.first
      end
      
      def variables_for_render
        super.merge :post => post
      end
    end
  end
end