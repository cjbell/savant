Savant::Application.routes.draw do
  namespace :admin do
    resources :posts
    resources :images, only: [:create]
  end
end
