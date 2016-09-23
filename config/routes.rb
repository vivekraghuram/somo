Rails.application.routes.draw do
  root to: 'pages#home'

  resources :forms, only: [:new, :create, :edit, :destroy] do
    post 'update', to: 'forms#update'

    # Twilio
    get 'twilio', to: 'twilio_responses#new'
    post 'twilio/start', to: 'twilio_responses#start'
    post 'twilio/receive', to: 'twilio_responses#receive'

    # Desktop
    get 'desktop', to: 'desktop_responses#new'
    get 'desktop/receive', to: 'desktop_responses#receive'
  end
end
