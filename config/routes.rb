Similar::Application.routes.draw do

  resources :artists do
    member do
      get :similar
    end
  end

  root to: "artists#index"

end
