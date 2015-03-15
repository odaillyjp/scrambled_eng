Rails.application.routes.draw do
  root 'courses#index'
  resources :courses do
    resources :challenges, param: :sequence_number  do
      post 'resolving', action: 'resolve', on: :member
      post 'next_word', action: 'teach_next_word', on: :member
    end
  end
end
