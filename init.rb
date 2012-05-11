#Breeze.configure do
  #Breeze::Content.register_class Breeze::Blog::Blog
#end

Breeze.hook :define_abilities do |user, abilities|
  abilities.instance_eval do
    can :manage, Breeze::Blog::Blog if user.editor?
  end
end

Breeze.hook :admin_menu do |menu, user|
  menu << { :name => "Blog", :path => "/admin/blog" } if user.can? :manage, Breeze::Content::Item
end

Breeze.hook :get_content_by_permalink do |permalink_or_content|
  binding.pry
  case permalink_or_content
  when Breeze::Content::Item then permalink_or_content
  when String then Breeze::Blog::Blog.find_by_permalink permalink_or_content
  else nil
  end
end

#Rails.application.config.to_prepare do
  #Breeze::Controller.helper Breeze::Blog::BlogHelper
#end
