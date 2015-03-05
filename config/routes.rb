Rails.application.routes.draw do
  root 'courses#index'
  resources :courses do
    resources :challenges do
      post 'resolving', action: 'resolve', on: :member
    end
  end
end
