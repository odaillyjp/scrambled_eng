Rails.application.routes.draw do
  root 'homes#index'

  resources :courses do
    get 'management', action: 'manage', on: :member

    resources :challenges, param: :sequence_number  do
      post 'resolving', action: 'resolve', on: :member
      post 'partial_answer', action: 'teach_partial_answer', on: :member
    end
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'sessions/create'
  delete '/session', to: 'sessions#destroy'
end
