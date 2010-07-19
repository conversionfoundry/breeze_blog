Rails.application.routes.draw do |map|
  scope "admin", :name_prefix => "admin", :module => "breeze/blog" do
    resources :blog do
      collection do
        post :setup_default
        put :switch
      end
    end
  end
end