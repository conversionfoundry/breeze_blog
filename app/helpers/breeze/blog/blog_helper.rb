module Breeze
  module Blog
    module BlogHelper
      unloadable
      
      def blog_switcher
        blogs = Breeze::Blog::Blog
        
        return content_tag :h2, "Blog" unless blogs.count > 1
        render :partial => "switcher", :locals => { :blogs => blogs.all }
      end
      
      def blog_menu
        content_tag :ul, [
          blog_menu_item("Blog overview", "/admin/blog"),
          blog_menu_item("Settings", "/admin/blog/settings")
        ].join.html_safe, :class => :actions
      end
      
      def blog_menu_item(name, path)
        content_tag :li, link_to(name.html_safe, path),
          :class => "#{:active if request.path == path}"
      end
    end
  end
end