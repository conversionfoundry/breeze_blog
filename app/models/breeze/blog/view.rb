module Breeze
  module Blog
    class View < Breeze::Content::PageView
      unloadable
      
      def blog
        content
      end
      
      def posts
        blog.posts.published.descending(:published_at)
      end
      
      def page
        (request && request.params[:page]) || 1
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
      
      def variables_for_render
        returning super do |vars|
          vars[:posts] = posts.paginate :per_page => blog.posts_per_page, :page => page
        end
      end
    end
  end
end