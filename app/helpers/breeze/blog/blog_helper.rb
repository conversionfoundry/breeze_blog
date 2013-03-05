module Breeze
  module Blog
    module BlogHelper
      def comments_link(post)
        str = if post.comments_count.blank? || post.comments_count.zero?
          "No comments"
        else
          pluralize post.comments_count, "comment"
        end
        link_to str, "#{post.permalink}#comments"
      end
      
      def replies_to(comment, comments)
        replies = comments.select { |c| c.parent_id == comment.id }
        unless replies.empty?
          content_tag :div, render(:partial => "/partials/blog/comment", :collection => replies, :locals => { :comments => comments }), :class => "comment-replies"
        end
      end
      
      def comment_form(params = {})
        comment = view.comment || post.comments.build(params)
        if comment.new_record?
          form_for comment, :as => :comment, :url => post.permalink, :method => :post, :builder => Breeze::Blog::FormBuilder do |form|
            render "/partials/blog/comment_form", :form => form, :comment => form.object
          end
        else
          render "/partials/blog/comment_posted", :comment => comment
        end
      end
      
      def body_with_linked_replies(comment)
        return comment.body unless comment.body =~ /\@/
        commenters = comment.post.commenters.select { |h| h[:created_at] < comment.created_at }
        comment.body.gsub(/\@([\w ]+)/) do |link|
          match = commenters.detect { |h| link.starts_with?("@" + h[:name]) }
          if match
            link.sub /^\@#{Regexp.escape(match[:name])}/, link_to("@#{match[:name]}", "#comment_#{match[:id]}", :class => "in-reply-to")
          else
            "@#{link}"
          end
        end
      end
      
    end
  end
end
