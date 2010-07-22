module Breeze
  module Blog
    class PostsController < Breeze::Admin::AdminController
      unloadable
      helper Breeze::Blog::BlogAdminHelper

      before_filter :check_for_blogs
      
      def show
      end
      
      def new
        @post = blog.posts.build :author => current_user
      end
      
      def create
        @post = blog.posts.build params[:post]
        if @post.save
          redirect_to blog_root_path
        else
          render :action => "new"
        end
      end
      
      def edit
      end
      
      def update
      end
      
      def destroy
      end

    protected
    
    # TODO: Methods getting blog are duplicated from BlogsController. Refactor to module. CB 21 July 2010.
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