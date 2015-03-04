Rails.application.routes.draw do
  root 'courses#index'
  resources :courses do
    resources :challenges, only: %i(show new create update delete)
  end
end
