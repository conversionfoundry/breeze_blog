module Breeze
  module Blog
    module BlogHelper
      unloadable
      
      def blog_switcher
        blogs = Breeze::Blog::Blog
        
        return "" unless blogs.count > 1
        render :partial => "switcher", :locals => { :blogs => blogs.all }
      end
    end
  end
end