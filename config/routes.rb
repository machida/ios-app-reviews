IosAppReviews::Application.routes.draw do

  resources :reviewers, only: [:index, :show] do
    get 'reviews' => 'reviews#by_reviewer'
  end

end
