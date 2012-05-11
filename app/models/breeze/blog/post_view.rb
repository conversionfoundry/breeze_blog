module Breeze
  module Blog
    class PostView < ArchiveView
      attr_accessor :slug
      attr_accessor :comment
      attr_accessor :preview_only
      
      def set_url_params(match)
        super
        @preview_only = match[12].present?
        self.slug = match[9] || match[12]
      end
      
      alias_method :preview_only?, :preview_only
      
      def posts
        (preview_only? ? blog.posts : super).where(:slug => slug)
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
