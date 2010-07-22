Rails.application.routes.draw do |map|
  scope "admin/blog", :module => "breeze/blog" do
    scope :name_prefix => "blog" do
      root :to => "blogs#index"
      controller :blogs do
        post :setup_default
        put :switch
        get :settings
        put :settings
      end
    end
    
    scope :name_prefix => "admin_blog" do
      resources :posts
      resources :comments
    end
  end
end