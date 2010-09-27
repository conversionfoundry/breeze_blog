# encoding: UTF-8
module Breeze
  module Blog
    class CommentMailer < Breeze::Mailer
      def comment_notification(comment)
        @comment = comment
        mail :to => comment.post.author.email, :from => comment.email, :subject => "New comment on ‘#{comment.post.title}’"
      end

    end
  end
end
