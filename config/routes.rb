IosAppReviews::Application.routes.draw do

  resources :reviewers, only: [:index, :show] do
    get 'reviews' => 'reviews#by_reviewer'
  end
  resources :reviews, only: [:index, :show] do
    get 'page/:page', action: :index, on: :collection
  end
  resources :apps, only: [:index, :show]

end
