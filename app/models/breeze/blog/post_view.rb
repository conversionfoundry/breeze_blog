module Breeze
  module Blog
    class PostView < ArchiveView
      unloadable
      
      attr_accessor :slug
      attr_accessor :comment
      
      def set_url_params(match)
        super
        self.slug = match[9]
      end
      
      def posts
        super.where(:slug => slug)
      end
      
      def post
        posts.first
      end

      def comment
        @comment ||= if controller.flash[:comment_id]
          blog.comments.find controller.flash[:comment_id]
        else
          nil
        end
      end
      
      def variables_for_render
        super.merge :post => post, :comments => post.comments.public, :comment => comment
      end
      
      def render!
        if request.post? && post.accepts_comments?
          @comment = post.comments.build(request.params[:comment])
          if @comment.save
            controller.flash[:comment_id] = @comment.id
            controller.send :redirect_to, post.permalink
          else
            super
          end
        else
          super
        end
      end
    end
  end
end