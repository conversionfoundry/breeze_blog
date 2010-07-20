module Breeze
  module Blog
    class BlogsController < Breeze::Admin::AdminController
      unloadable
      helper Breeze::Blog::BlogHelper
      
      before_filter :check_for_blogs, :except => [ :setup_default ]
      
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
      
    protected
      def check_for_blogs
        unless blog
          render :action => "no_blog"
        end
      end
    
      def blog
        @blog ||= if session[:blog_id]
          Blog.find session[:blog_id]
        else
          Blog.first
        end
      end
      helper_method :blog
    end
  end
end