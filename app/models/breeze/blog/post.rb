module Breeze
  module Blog
    class Post
      include Mongoid::Document
      include Mongoid::Timestamps
      identity :type => String

      include Breeze::Content::Mixins::Permalinks
      include Breeze::Content::Mixins::Markdown
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      has_many_related :comments, :class_name => "Breeze::Blog::Comment" do
        def public
          @parent.comments.published.ascending(:created_at)
        end
      end
      has_many_related :categories, :class_name => "Breeze::Blog::Category", :stored_as => :array
      belongs_to_related :category, :class_name => "Breeze::Blog::Category"
      
      field :title
      field :slug
      field :body, :markdown => true
      field :intro, :markdown => true
      field :published_at, :type => Time
      field :comments_count, :type => Integer, :default => 0

      # newly added seo fields
      field :seo_title
      field :seo_meta_description
      field :seo_meta_keywords
      
      validates_presence_of :title, :slug, :body
      validates_presence_of :author_id, :message => "must be selected"

      before_destroy :destroy_children
      before_save :regenerate_permalink!
      
      scope :published, lambda { where(:published_at.lt => Time.now.utc) }
      scope :pending,   lambda { where(:published_at.gt => Time.now.utc) }
      scope :draft,     where(:published_at => nil)
      
      def summary
        return intro if intro.present?

        @generated_summary ||= begin
          words, stripped = [], body(:source)
          word_limit = blog.try(:post_summary_length) || 100

          while !stripped.blank? && words.size < word_limit
            stripped.sub! /^([^\s]+\s*)/ do
              words << $1
              ""
            end
            stripped.strip!
          end
          summary = words.join
          summary.sub!(/[\s\.\,]*$/, '...') unless stripped.blank?
          RDiscount.new(summary).to_html.html_safe
        end
      end
      
      # Regardless of the published state of the post,
      # returns a date suitable for public display.
      def time
        (published_at || created_at).try :in_time_zone
      end
      
      def published_at=(time)
        case time
        when Array then write_attribute :published_at, Time.zone.local(*(time.map(&:to_i)))
        else write_attribute :published_at, time
        end
      end
      
      def published_date
        (published_at || Time.now).in_time_zone.to_date
      end
      
      def published_date=(date)
        
      end
      
      def published_time
        (published_at || Time.now).in_time_zone.to_time
      end
      
      def published_time=(time)
        
      end
      
      def published?
        status == :published
      end
      
      def publish
        self.published_at = Time.now
      end
      
      def publish!
        publish
        save
      end
           
      def pending?
        status == :pending
      end
      
      def draft?
        status == :draft
      end
      
      def unpublish
        self.published_at = nil
      end
      
      def unpublish!
        unpublish
        save
      end
           
      def status
        if published_at.present?
          if published_at <= DateTime.now
            :published
          else
            :pending
          end
        else
          :draft
        end
      end
      
      def status=(new_status)
        case new_status.to_sym
        when :published then publish unless published?
        when :draft     then unpublish unless draft?
        # TODO: work out what to do with status=(:pending)
        end
      end
      
      def accepts_comments?
        published?
      end
      
      def commenters
        @commenters ||= comments.only(:name, :id, :created_at).descending(:created_at).all.map do |c|
          { :name => c.name, :id => c.id, :created_at => c.created_at }
        end
      end

      def category_ids=(values)
        write_attribute :category_ids, Array(values).reject(&:blank?)
      end
      
      def process(attrs={})
        # TODO: this probably belongs somewhere else
        attributes = returning({}) do |hash|
          indexed = {}
          
          attrs.each_pair do |k, v|
            if k =~ /^([\w_]+)\((\d+)i\)/
              indexed[$1] ||= {}
              indexed[$1][$2.to_i] = v
            else
              hash[k] = v
            end
          end
          
          indexed.each_pair do |k, v|
            hash[k] = v.to_a.sort_by(&:first).map(&:last)           
          end
        end
        super attributes
      end
      
      def draft_permalink
        "#{blog.permalink}/draft/#{slug}"
      end
      
      def next
        @next ||= self.class.where(:published_at.gt => published_at).order_by(:published_at.asc).first
      end
      
      def previous
        @previous ||= self.class.where(:published_at.lt => published_at).order_by(:published_at.desc).first
      end
      
    protected
      def regenerate_permalink!
        self.permalink = "#{blog.permalink}/#{category.slug}/#{slug}" unless blog.nil? || slug.blank?
      end
      
      def date_part
        if published_at?
          published_at.in_time_zone.strftime "/%Y/%m/%d"
        else
          "/draft"
        end
      end

      def destroy_children
        comments.map(&:destroy)
      end
   
    end
  end
end
