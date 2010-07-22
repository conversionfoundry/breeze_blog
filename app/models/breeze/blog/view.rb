module Breeze
  module Blog
    class View < Breeze::Content::View
      def posts
        Post.descending(:published_at)
      end
      
      def with_url_params(match)
        returning dup do |view|
          view.set_url_params(match)
        end
      end
      
      def set_url_params(match)
      end
      
      def template
        if content.template.blank?
          "breeze/blog/#{name}"
        else
          content.template
        end
      end
    end
  end
end