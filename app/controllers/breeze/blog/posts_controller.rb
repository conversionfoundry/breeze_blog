module Breeze
  module Blog
    class PostsController < Breeze::Blog::Controller
      unloadable

      before_filter :check_for_blogs
      
      def index
        @posts = blog.posts
      end
      
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
    end
  end
end