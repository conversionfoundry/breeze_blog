module Breeze
  module Blog
    module Spam
      class Strategy
        include Mongoid::Document
        identity :type => String

        embedded_in :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :spam_strategy
      
        def submit(comment)
        end
      end
    end
  end
end