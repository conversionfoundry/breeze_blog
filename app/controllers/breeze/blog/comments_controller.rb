module Breeze
  module Blog
    class CommentsController < Breeze::Blog::Controller
      unloadable
      
      def index
        if request.xhr?
          Rails.logger.info "XHR".green
          @comments = blog.comments.send(params[:tab]).paginate(:page => params[:page] || 1)
          render :partial => "comments", :locals => { :comments => @comments }, :layout => false
        end
      end
      
      def approve
        comment.try :publish!
        render :action => :change
      end
      
      def spam
        comment.try :spam!
        render :action => :change
      end
      
      def mass_update
        @comments = blog.comments.find params[:comment_ids]
        @comments.each do |comment|
          comment.update_attributes params[:comment]
        end
      end
      
      def mass_destroy
        @comments = blog.comments.find params[:comment_ids]
        @comments.map &:destroy
      end
      
      def destroy
        comment.try :destroy
      end
      
    protected
      def comment
        @comment ||= blog.comments.find params[:id]
      end
    end
  end
end