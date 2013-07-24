IosAppReviews::Application.routes.draw do
  root 'reviews#index'
  resources :reviews, only: :index do
    get 'page/:page', action: :index, on: :collection
  end
end
