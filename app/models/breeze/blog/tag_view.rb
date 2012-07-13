module Breeze
  module Blog
    class TagView < IndexView
      attr_accessor :tag_slug
      
      def set_url_params(match)
        super
        self.tag_slug = match[11]
      end
            
      def tags
        @tags ||= tag_slug.split(",").map { |t| CGI.unescape(t) }
      end
      
      def tag
        tags.first
      end
      
      def posts
        super.where :tags.all => tags
      end
      
      def variables_for_render
        returning super do |vars|
          vars[:tags] = tags
          vars[:tag] = tag
        end
      end
      
    end
  end
end

