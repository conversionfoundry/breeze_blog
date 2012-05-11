module Breeze
  module Blog
    class Engine < ::Rails::Engine
      #include Breeze::Engine

      isolate_namespace Breeze::Blog
    end
  end
end

