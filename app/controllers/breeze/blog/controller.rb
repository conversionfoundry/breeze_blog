module Breeze
  module Blog
    class Controller < Breeze::Admin::AdminController
      helper Breeze::Blog::BlogAdminHelper
      helper Breeze::Blog::BlogHelper
      before_filter :check_for_blogs, :except => [ :setup_default ]

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