module Breeze
  module Blog
    class BlogsController < Breeze::Blog::Controller
      unloadable
      
      def index
        @posts = blog.posts
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
    end
  end
end