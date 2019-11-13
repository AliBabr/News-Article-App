# frozen_string_literal: true

class Api::V1::SubscriptionsController < ApplicationController
  before_action :authenticate # call back for validating user

  def create
    if params[:plan_tok].present? && Plan.find_by_plan_tok(params[:plan_tok]).present?
      response = StripePayment.new(@user).create_subscription(params[:plan_tok].to_s)
      if response.present?
        save_subscription(response)
      else
        render json: { message: 'Something went wrong with your card please check...' }, status: 401
      end
    else
      render json: { message: 'Please provide valid plan Id' }, status: 401
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def upgrade_subscription
    if params[:plan_tok].present? && Plan.find_by_plan_tok(params[:plan_tok]).present?
      response = StripePayment.new(@user).create_subscription(params[:plan_tok].to_s)
      if response.present?
        save_upgrade(response)
      else
        render json: { message: 'Something went wrong with your card please check...' }, status: 401
      end
    else
      render json: { message: 'Please provide valid plan Id' }, status: 401
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def update_subscription
    curr_subs = @user.subscriptions.where(status: 'active').first
    curr_subs.update(subscription_params)
    if curr_subs.errors.any?
      render json: @user.errors.messages, status: 400
    else
      render json: { first_name: curr_subs.first_name, last_name: curr_subs.last_name, street_address: curr_subs.street_address, city: curr_subs.city, state: curr_subs.state, zip_code: curr_subs.zip_code, plan_name: curr_subs.plan.name, plan_price: curr_subs.plan.price, plan_description: curr_subs.plan.description }, status: 200
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def get_subscription
    curr_subs = @user.subscriptions.where(status: 'active').first
    render json: { first_name: curr_subs.first_name, last_name: curr_subs.last_name, street_address: curr_subs.street_address, city: curr_subs.city, state: curr_subs.state, zip_code: curr_subs.zip_code, plan_name: curr_subs.plan.name, plan_price: curr_subs.plan.price, plan_description: curr_subs.plan.description }, status: 200
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to cancel subscription
  def cancel_subscription
    response = StripePayment.new(@user).delete_subscription
    if response
      CancelSubscriptionMailer.cancel_subscription(@user).deliver
      render json: { message: 'Your subscription has been cancelled' }, status: 200
    else
      render json: { message: 'something went wrong..' }, status: :bad_request
    end
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def subscription_params
    params.permit(:first_name, :last_name, :street_address, :city, :state, :zip_code)
  end

  # Helper Methode for create subscription
  def save_subscription(subscription)
    @user.subscriptions.each do |sub|
      sub.update(status: nil)
    end
    sub = Subscription.new(subscription_params)
    sub.status = 'active'; sub.subscription_tok = subscription.id; sub.description = "New subscription against plan #{params[:plan_id]}"
    sub.user = @user
    sub.plan = Plan.find_by_plan_tok(params[:plan_tok])
    if sub.save
      render json: { message: 'You subscribed successfully!' }, status: 200
    else
      render json: sub.errors.messages, status: 400
    end
    SubscriptionMailer.subscribe(@user, sub).deliver
  end

  def save_upgrade
    curr_subs = @user.subscriptions.where(status: 'active').first
    @user.subscriptions.each do |sub|
      sub.update(status: nil)
    end
    sub = Subscription.new(first_name: curr_subs.first_name, last_name: curr_subs.last_name, street_address: curr_subs.street_address, city: curr_subs.city, state: curr_subs.state, sip_code: curr_subs.zip_code)
    sub.status = 'active'; sub.subscription_tok = subscription.id; sub.description = "New subscription against plan #{params[:plan_id]}"
    sub.user = @user
    sub.plan = Plan.find_by_plan_tok(params[:plan_tok])
    if sub.save
      render json: { message: 'You subscription plan upgraded successfully!' }, status: 200
    else
      render json: sub.errors.messages, status: 400
    end
    UpgradeSubscriptionMailer.upgrade(@user, sub).deliver
  end
end
