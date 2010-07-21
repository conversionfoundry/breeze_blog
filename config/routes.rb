Rails.application.routes.draw do |map|
  
  # scope "admin", :name_prefix => "admin", :module => "breeze/blog" do
  #   resources :blog do
  #     collection do
  #       post :setup_default
  #       put :switch
  #       get :settings
  #       put :settings
  #     end
  #   end
  #   scope "blog", :name_prefix => "blog" do
  #     resources :posts
  #   end
  #   # resources :posts
  # end

  scope "admin/blog", :name_prefix => "blog", :module => "breeze/blog" do
    root :to => "blogs#index"
    controller :blogs do
      post :setup_default
      put :switch
      get :settings
      put :settings
    end
    resources :posts, :name_prefix => "admin"
  end
  
end