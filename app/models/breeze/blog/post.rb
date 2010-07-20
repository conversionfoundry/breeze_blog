module Breeze
  module Blog
    class Post
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      
      field :title
      field :slug
      field :body
      
      validates_presence_of :title
      validates_presence_of :slug
      validates_presence_of :body
    end
  end
end