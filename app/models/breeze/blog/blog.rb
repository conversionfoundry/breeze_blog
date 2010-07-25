module Breeze
  module Blog
    class Blog < Breeze::Content::Page
      unloadable

      field :posts_per_page, :type => Integer, :default => 5
      has_many_related :posts, :class_name => "Breeze::Blog::Post"
      has_many_related :comments, :class_name => "Breeze::Blog::Comment"
      embeds_one :spam_strategy, :class_name => "Breeze::Blog::Spam::Strategy"
      
      before_create :create_default_views
      before_create :create_default_spam_filtering
      
      def view_for(controller, request)
        if controller.admin_signed_in? && request.params[:view]
          returning views.by_name(request.params[:view]) do |view|
            view.with_url_params Breeze::Blog::PERMALINK.match(permalink)
          end
        else  
          view_from_permalink request.path
        end
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
      
      def spam_strategy_attributes=(attrs)
        if attrs[:_type]
          klass = attrs[:_type].constantize
          self.spam_strategy = klass.new(attrs.except(:id, :_type))
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
      
      def create_default_spam_filtering
        self.spam_strategy = Breeze::Blog::Spam::NoStrategy.new
      end
    end
  end
end