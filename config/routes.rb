Similar::Application.routes.draw do

  resources :artists do
    member do
      get :similar
    end
  end

  match "users/:username", to: "users#show"

  root to: "artists#index"

end
