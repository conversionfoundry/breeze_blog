module Breeze
  module Blog
    class Engine < ::Rails::Engine
      #include Breeze::Engine

      isolate_namespace Breeze::Blog
      
      config.to_prepare do
        ApplicationController.helper(Breeze::Blog::BlogHelper)
        Breeze::Content.register_class Breeze::Blog::Blog
      end
      
    end
  end
end

