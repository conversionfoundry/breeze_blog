module Breeze
  module Blog
    class Post
      unloadable
      
      include Mongoid::Document
      include Mongoid::Timestamps
      
      belongs_to_related :blog, :class_name => "Breeze::Blog::Blog", :inverse_of => :posts
      belongs_to_related :author, :class_name => "Breeze::Admin::User"
      
      field :title
      field :slug
      field :body
      field :published_at, :type => DateTime
      
      validates_presence_of :title, :slug, :body
      validates_presence_of :author_id, :message => "must be selected"
    end
  end
end