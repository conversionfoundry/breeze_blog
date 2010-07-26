Rails.application.routes.draw do |map|
  scope "admin/blog", :module => "breeze/blog", :name_prefix => "admin_blog" do
    root :to => "blogs#index"
    controller :blogs do
      post :setup_default
      put :switch
      get :settings
      put :settings
      get :new_spam_strategy
    end

    resources :posts
    put "comments(.:format)" => "comments#mass_update"
    delete "comments(.:format)" => "comments#mass_destroy"
    resources :comments do
      member do
        put :approve
        put :spam
      end
    end
    resources :categories do
      collection do
        put :reorder
      end
    end    
  end
end