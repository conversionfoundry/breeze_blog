module Breeze
  module Blog
    module Spam
      class NoStrategy < Strategy
        def self.label
          "No automatic spam filtering"
        end
      end
    end
  end
end