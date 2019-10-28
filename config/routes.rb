Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          post :sign_in
          post :sign_up
          post :log_out
          post :update_password
          post :update_account
          post :forgot_password
          post :reset_password
          post :toggle_notification
        end
        member do
          get :reset
        end
      end
      resources :news do
        collection do
          get :search
        end
      end
      resources :questions do
        collection do
          put :check_answer
        end
      end
      post '/notifications/toggle_notification', to: 'notifications#toggle_notification'
      resources :places, only: :index
    end
  end

  root to: "home#index"

end
