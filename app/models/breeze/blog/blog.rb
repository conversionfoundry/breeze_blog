module Breeze
  module Blog
    class Blog < Breeze::Content::Page
      has_many_related :posts, :class_name => "Breeze::Blog::Post"
    end
  end
end