# frozen_string_literal: true

class Api::V1::SubscriptionsController < ApplicationController
  before_action :authenticate # call back for validating user

  def create
    if params[:plan_tok].present? && Plan.find_by_plan_tok(params[:plan_tok]).present?
      response = StripePayment.new(@user).create_subscription(params[:plan_tok].to_s)
      if response.present?
        save_subscription(response)
      else
      end
    else
      render json: {message: "Please provide valid plan Id"}, status: 401
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to cancel subscription
  def cancel_subscription
   response =  StripePayment.new(@user).delete_subscription
   if response
     render json: {message: "Your subscription has been cancelled"}, status: 200
   else
      render json: {message: "something went wrong.."}, status: :bad_request
   end
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end


  private

  # Helper Methode for create subscription
  def save_subscription(subscription)
    @user.subscriptions.each do |sub|
      sub.update(status: nil)
    end
    sub = Subscription.new(status: 'active', subscription_tok: subscription.id, description: "New subscription against plan #{params[:plan_id]}")
    sub.user = @user
    sub.plan = Plan.find_by_plan_tok(params[:plan_tok])
    if sub.save
      render json: {message: "You subscribed successfully!"}, status: 200
    else
      render json: sub.errors.messages, status: 400
    end
  end
end
