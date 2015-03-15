Rails.application.routes.draw do
  root 'courses#index'
  resources :courses do
    resources :challenges, param: :sequence_number  do
      post 'resolving', action: 'resolve', on: :member
      post 'partial_answer', action: 'teach_partial_answer', on: :member
    end
  end
end
