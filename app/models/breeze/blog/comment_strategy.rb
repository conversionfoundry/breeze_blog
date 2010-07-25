module Breeze
  module Blog
    class CommentStrategy
      include Mongoid::Document
      identity :type => String

      embedded_in :blog, :inverse_of => :comment_strategy
      
      def submit(comment)
      end
    end
  end
end