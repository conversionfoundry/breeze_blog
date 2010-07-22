module Breeze
  module Blog
    class Blog < Breeze::Content::Page
      unloadable
      
      has_many_related :posts, :class_name => "Breeze::Blog::Post"
      
      before_create :create_default_views
      
      def view_for(controller, request)
        view_from_permalink request.path
      end
      
      def view_from_permalink(permalink)
        match = Breeze::Blog::PERMALINK.match(permalink) || {}
        view = if match[3] # year/month/day
          if match[9] # slug
            post_view
          else
            archive_view
          end
        elsif match[10] # category
          category_view
        elsif match[11] # tag
          tag_view
        else
          index_view
        end
        
        view.with_url_params match
      end
      
      def method_missing(sym, *args, &block)
        if sym.to_s =~ /^(.+)_view$/
          view_name = $1
          views.detect { |v| v.name == view_name } ||
          views.build({ :name => view_name }, "Breeze::Blog::#{view_name.camelize}View".constantize)
        else
          super
        end
      end
      
      def self.find_by_permalink(permalink)
        if permalink =~ Breeze::Blog::PERMALINK
          permalink = $`
          puts permalink.red
          where(:permalink => permalink).first
        end
      end
      
    protected
      def create_default_views
        index_view
        archive_view
        category_view
        tag_view
        post_view
      end
    end
  end
end