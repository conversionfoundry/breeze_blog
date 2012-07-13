module Breeze
  module Blog
    class PostView < ArchiveView
      attr_accessor :permalink
      attr_accessor :comment
      attr_accessor :preview_only
      
      def set_url_params(permalink)
        super
        self.permalink = permalink
      end
      
      alias_method :preview_only?, :preview_only
      
      def posts
        require 'pry'
        binding.pry
        (controller.admin_signed_in? ? blog.posts : blog.posts.published).where(:permalink => permalink)
      end
      
      def post
        @post ||= posts.first
      end

      def comment
        @comment ||= if controller.flash[:comment_id]
          blog.comments.find controller.flash[:comment_id]
        else
          nil
        end
      end
      
      def variables_for_render
        super.merge :post => post, :comments => post.present? ? post.comments.public : [], :comment => comment
      end
      
      def render!
        if request.post? && post.accepts_comments?
          @comment = post.comments.build(request.params[:comment])
          @comment.blog_id = blog.id
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
