module Breeze
  module Blog
    class PostsController < Breeze::Blog::Controller
      unloadable
      
      def index
        @posts = blog.posts # TODO Order result set
      end
      
      def show
      end
      
      def new
        @post = blog.posts.build :author => current_user
      end
      
      def create
        @post = blog.posts.build params[:post]
        if @post.save
          redirect_to admin_blog_posts_path
        else
          render :action => "new"
        end
      end
      
      def edit
        @post = blog.posts.find params[:id]
      end
      
      def update
        @post = blog.posts.find params[:id]
        if @post.update_attributes(params[:post])
          redirect_to admin_blog_posts_path
        else
          render :action => "edit"
        end
      end
      
      def destroy
        @post = blog.posts.find params[:id]
        @post.try :destroy
      end
      
    end
  end
end