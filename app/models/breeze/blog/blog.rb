module Breeze
  module Blog
    class Blog < Breeze::Content::Page
      extend ActiveSupport::Memoizable
      
      unloadable

      field :posts_per_page, :type => Integer, :default => 5
      field :post_summary_length, :type => Integer, :default => 100
      field :comment_moderation, :type => Boolean, :default => false
      field :comment_notifications, :type => Boolean, :default => true
      has_many_related :posts, :class_name => "Breeze::Blog::Post"
      has_many_related :comments, :class_name => "Breeze::Blog::Comment"
      has_many_related :categories, :class_name => "Breeze::Blog::Category"
      embeds_one :spam_strategy, :class_name => "Breeze::Blog::Spam::Strategy"
      field :rss_title
      field :rss_description
      
      before_create :create_default_views
      before_create :create_default_spam_filtering
      after_destroy :destroy_posts_and_categories
      before_save :fix_post_permalinks
      
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
        elsif match[12] # unpublished
          post_view
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
          where(:permalink => permalink).first
        end
      end
      
      def spam_strategy_attributes=(attrs)
        if attrs[:_type]
          klass = attrs[:_type].constantize
          self.spam_strategy = klass.new(attrs.except(:id, :_type))
        end
      end
      
      def rss_link
        permalink(:include_domain) + ".rss"
      end
      
      def tags
        @tags ||= posts.published.only(:tags).collect(&:tags).flatten
      end
      memoize :tags
      
      def unique_tags
        tags.uniq
      end
      
      def tags_with_frequencies
        returning Hash.new do |hash|
          tags.each do |tag|
            hash[tag] ||= 0
            hash[tag] += 1
          end
        end
      end
      memoize :tags_with_frequencies
      
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
      
      def destroy_posts_and_categories
        posts.destroy_all
        categories.destroy_all
      end
      
      def fix_post_permalinks
        if permalink_changed?
          # TODO: probably not the best idea to load them all at once
          posts.all.each do |post|
            post.blog = self # prevent loading from the database
            post.send :regenerate_permalink!
            post.save!
          end
        end
      end
    end
  end
end