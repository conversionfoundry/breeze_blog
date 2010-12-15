module Breeze
  module Blog
    module BlogAdminHelper
      def blog_switcher
        blogs = Breeze::Blog::Blog
        
        return content_tag :h2, "Blog" unless blogs.count > 1
        render :partial => "/breeze/blog/blogs/switcher", :locals => { :blogs => blogs.all }
      end
      
      def blog_menu
        drafts_count = blog.posts.draft.count
        pending_comments_count = blog.comments.pending.count
        content_tag :ul, [
          blog_menu_item("Blog overview", admin_blog_root_path),
          blog_menu_item("Posts #{"<small title=\"#{pluralize drafts_count, "draft"}\">#{drafts_count}</small>" unless drafts_count.zero?}", /#{admin_blog_posts_path}/),
          blog_menu_item("Comments #{"<small title=\"#{pluralize pending_comments_count, "comment"} pending moderation\">#{pending_comments_count}</small>" unless pending_comments_count.zero?}", admin_blog_comments_path),
          blog_menu_item("Settings", admin_blog_settings_path),
          blog_menu_item("View blog", blog.permalink, :target => :_blank)
        ].join.html_safe, :class => :actions
      end
      
      def blog_menu_item(name, path, options = {})
        content_tag :li, link_to(name.html_safe, path.is_a?(Regexp) ? path.source : path.to_s, options),
          :class => "#{:active if path === request.path}"
      end
      
      def at_a_glance(count, label, link = nil, options = {})
        returning "" do |html|
          html << "<tr>"
          html << "<td class=\"count\">#{count}</td>"
          html << "<td class=\"label\">"
          html << link_to_unless(link.blank?, label.gsub(/(\w+)\(s\)/) { count == 1 ? $1 : $1.pluralize }, link, options)
          html << "</td>"
          html << "</tr>"
        end.html_safe
      end
      
      def last_published(blog)
        latest_post = blog.posts.published.last
        if latest_post.present?
          post_date = latest_post.published_at.to_date
          today = Time.zone.now.to_date
          if post_date == today
            "You last published a blog post <strong>today</strong>. Great stuff!"
          else
            "It's been <strong>#{pluralize((today - post_date).to_i, "day")}</strong> since you last published a blog post. " + link_to("Get writing!", new_admin_blog_post_path)
          end
        else
          "You haven't published any blog posts yet. " + link_to("Get writing!", new_admin_blog_post_path)
        end.html_safe
      end
    end
  end
end