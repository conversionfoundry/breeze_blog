module Breeze
  module Admin
    module Blog
      class PostsController < Breeze::Admin::Blog::Controller
        def index
          @posts = blog.posts # TODO Order result set
        end
        
        def draft
          render :partial => "posts", :locals => { :posts => blog.posts.draft.paginate(:page => params[:page], :per_page => 10), :view => :draft }, :layout => false
        end
        
        def scheduled
          render :partial => "posts", :locals => { :posts => blog.posts.pending.paginate(:page => params[:page], :per_page => 10), :view => :pending }, :layout => false
        end
        
        def published
          render :partial => "posts", :locals => { :posts => blog.posts.published.paginate(:page => params[:page], :per_page => 10), :view => :published }, :layout => false
        end
        
        def show
          if (@post = blog.posts.find params[:id])
            redirect_to @post.permalink
          end
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
            flash[:notice] = "Your post was saved. <a href=\"#{@post.permalink}\">View your changes</a>, <a href=\"#{admin_blog_posts_path}\">return to the list of posts</a>, or close this message to continue editing."
            redirect_to edit_admin_blog_post_path(@post)
          else
            render :action => "edit"
          end
        end
        
        def destroy
          @post = blog.posts.find params[:id]
          @post.try :destroy
        end
        
        def mass_update
          @posts = blog.posts.find params[:post_ids]
          @posts.each do |post|
            post.update_attributes params[:post]
          end
        end
        
        def mass_destroy
          @posts = blog.posts.find params[:post_ids]
          @posts.map &:destroy
        end
        
      end
    end
  end
end
