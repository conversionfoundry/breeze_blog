module Breeze
  module Blog
    class View < Breeze::Content::PageView
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
        dup.tap do |view|
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
        super.tap do |vars|
          vars[:posts] = posts.paginate :per_page => blog.posts_per_page, :page => page
          # vars[:posts] = if request.format.html?
          #   posts.paginate :per_page => blog.posts_per_page, :page => page
          # else
          #   posts
          # end
        end
      end
      
      def render_as_rss
        controller.send :render, :file => "/layouts/breeze/blog/index.rss.builder", :locals => { :blog => blog, :posts => posts }
      end
    end
  end
end
