Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :articles do
    resources :comments, only: [:index, :create]
  end

  post 'login', to: 'access_tokens#create'
  post '/sign_up', to: 'registrations#create'  
  delete 'logout', to: 'access_tokens#destroy'
end
