Breeze.configure do
  Breeze::Content.register_class Breeze::Blog::Blog
end

Breeze.hook :define_abilities do |user, abilities|
  abilities.instance_eval do
    can :manage, Breeze::Content::Blog if user.editor?
  end
end

Breeze.hook :admin_menu do |menu, user|
  menu << { :name => "Blog", :path => "/admin/blog" } if user.can? :manage, Breeze::Content::Item
end
