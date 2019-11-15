# frozen_string_literal: true

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
          post :save_stripe_token
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
      resources :polls do
        collection do
          put :submit_answer
        end
      end
      resources :rewards do
        collection do
          get :points
          put :redeem
        end
      end
      resources :plans, only: %i[create update destroy index] do
        collection do
          delete :delete_plan
        end
      end
      resources :coupons, only: %i[create index] do
        collection do
          delete :delete_coupon
        end
      end
      resources :subscriptions, only: [:create] do
        collection do
          put :cancel_subscription
          put :update_subscription
          post :upgrade_subscription
          get :get_subscription
        end
      end

      post '/notifications/toggle_notification', to: 'notifications#toggle_notification'
      resources :places, only: :index
      mount StripeEvent::Engine, at: '/payment.events.com'
    end
  end

  root to: 'home#index'
end
