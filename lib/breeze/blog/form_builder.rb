module Breeze
  module Blog
    class FormBuilder < Breeze::Admin::FormBuilder
      unloadable
      
      def error_messages
        template.render "/partials/blog/error_messages", :target => object, :object_name => :form
      end
    end
  end
end