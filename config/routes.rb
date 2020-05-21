# frozen_string_literal: true

Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          post :sign_in
          post :web_sign_in
          post :sign_up
          post :log_out
          post :update_password
          post :save_device_token
          post :update_account
          post :forgot_password
          post :reset_password
          post :toggle_notification
          post :save_stripe_token
          get :get_user
        end
        member do
          get :reset
        end
      end
      resources :news, only: %i[index] do
        collection do
          get :search
          get :comic_news
          get :gaming_news
          get :get_news_details
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
          put :ship_to_me_redemption
        end
      end
      resources :plans, only: %i[create update destroy index] do
        collection do
          delete :delete_plan
        end
      end

      resources :installments, only: %i[create update destroy index] do
        collection do
          delete :delete_installment
        end
      end

      resources :coupons, only: %i[create index] do
        collection do
          delete :delete_coupon
        end
      end

      resources :web, only: %i[create index] do
        collection do
          post :checkout
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

      post "/notifications/toggle_notification", to: "notifications#toggle_notification"
      resources :places, only: :index
      mount StripeEvent::Engine, at: "/payment.events.com"
    end
  end

  root to: "home#index"
end
