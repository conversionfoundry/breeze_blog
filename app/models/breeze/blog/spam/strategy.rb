module Breeze
  module Blog
    module Spam
      class Strategy
        include Mongoid::Document
        identity :type => String

        embedded_in :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :spam_strategy
      
        def submit(comment)
          Breeze.queue comment, :deliver_notification!
        end
        
        def self.partial
          "/breeze/blog/blogs/spam/" + name.demodulize.underscore
        end
        
        def partial
          self.class.partial
        end
        
        def self.label
          name.demodulize.sub(/Strategy$/, "").underscore.humanize
        end
        
        def self.strategies
          @strategies ||= returning([]) do |classes|
            Dir[File.join(File.dirname(__FILE__), "*.rb")].each do |f|
              require f
            end
            subclasses.map(&:to_s).each do |k|
              classes << k
            end
          end
          @strategies.map &:constantize
        end
      end
    end
  end
end