module Breeze
  module Blog
    class BlogsController < Breeze::Blog::Controller
      unloadable
      
      def index
        @awaiting_moderation = blog.comments.pending
        @awaiting_reply = blog.comments.awaiting_reply
      end
      
      def setup_default
        @blog = Blog.new :title => "Blog", :parent_id => Breeze::Content::NavigationItem.root.first.try(:id)
        @blog.save!
        redirect_to admin_blogs_path
      end
      
      def switch
        session[:blog_id] = params[:blog]
        redirect_to :action => "index"
      end
      
      def new_spam_strategy
        
      end
      
      def settings
        if request.put?
          blog.update_attributes params[:blog]
          redirect_to admin_blog_settings_path
        end
      end
    end
  end
end