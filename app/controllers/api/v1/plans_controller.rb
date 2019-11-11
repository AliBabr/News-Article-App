# frozen_string_literal: true

class Api::V1::PlansController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_plan, only: %i[update destroy]
  before_action :is_admin

  def create
    plan = Plan.new(plan_params)
    if plan.save
      render json: { id: plan.id, name: plan.name, description: plan.description, price: plan.price, currency: plan.currency, duration: plan.duration, plan_tok: plan.plan_tok }, status: 200
    else
      render json: plan.errors.messages, status: 400
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def update
    @plan.update(plan_params)
    if @plan.errors.any?
      render json: @plan.errors.messages, status: 400
    else
      render json: { id: @plan.id, name: @plan.name, description: @plan.description, price: @plan.price, currency: @plan.currency, duration: @plan.duration, plan_tok: @plan.plan_tok }, status: 200
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def destroy
    @plan.destroy
    render json: { message: 'plan deleted successfully!' }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def plan_params # permit  plan params
    params.permit(:name, :price, :currency, :duration, :plan_tok, :description)
  end

  def set_plan # instance methode for plan
    @plan = Plan.find_by_id(params[:id])
    if @plan.present?
      return true
    else
      render json: { message: 'plan Not found!' }, status: 404
    end
  end

  def is_admin
    if @user.role == 'admin'
      true
    else
      render json: { message: 'Only admin can create/update/destroy plans!' }
    end
  end
end
