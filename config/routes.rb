Rails.application.routes.draw do |map|
  scope "admin/blog", :name_prefix => "blog", :module => "breeze/blog" do
    root :to => "blogs#index"
    controller :blogs do
      post :setup_default
      put :switch
      get :settings
      put :settings
    end
    
    resources :posts, :name_prefix => "admin"
    resources :comments, :name_prefix => "admin"
  end
end