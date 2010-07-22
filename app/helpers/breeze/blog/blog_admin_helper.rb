module Breeze
  module Blog
    module BlogAdminHelper
      unloadable
      
      def blog_switcher
        blogs = Breeze::Blog::Blog
        
        return content_tag :h2, "Blog" unless blogs.count > 1
        render :partial => "/breeze/blog/blogs/switcher", :locals => { :blogs => blogs.all }
      end
      
      def blog_menu
        pending_comments_count = blog.comments.pending.count
        content_tag :ul, [
          blog_menu_item("Blog overview", "/admin/blog"),
          blog_menu_item("Posts", "/admin/blog/posts"),
          blog_menu_item("Comments #{"<small>#{pending_comments_count}</small>" unless pending_comments_count.zero?}", "/admin/blog/comments"),
          blog_menu_item("Settings", "/admin/blog/settings"),
          blog_menu_item("View blog", blog.permalink, :target => :_blank)
        ].join.html_safe, :class => :actions
      end
      
      def blog_menu_item(name, path, options = {})
        content_tag :li, link_to(name.html_safe, path, options),
          :class => "#{:active if request.path == path}"
      end
    end
  end
end