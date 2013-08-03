Savant::Application.routes.draw do
  namespace :admin do
    resources :posts
  end
end
