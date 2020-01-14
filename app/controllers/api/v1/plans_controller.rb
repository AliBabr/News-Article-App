# frozen_string_literal: true

class Api::V1::PlansController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_plan, only: %i[ delete_plan ]
  before_action :is_admin, only: %i[create delete_plan]

  def create
    response = StripePayment.new(@user).create_plan(params, params[:amount].to_i * 100)
    if response.present?
      plan = Plan.new(plan_params)
      plan.id = response.id
      if plan.save
        render json: { plan_id: plan.id, name: plan.name, description: plan.description, amount: plan.amount, currency: plan.currency, interval: plan.interval, interval_count: plan.interval_count }, status: 200
      else
        render json: plan.errors.messages, status: 400
      end
    else
      render json: { message: "Something went wrong please check your parameters all parametrs are compulsory" }
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    plan = Plan.all
    plans = []
    all_installments = []
    plan.each do |pl|
      all_installments = []
      if pl.installments.present?
        pl.installments.each do |ins|
          all_installments << { plan_id: pl.id, name: pl.name, amount: pl.amount, currency: pl.currency, interval: pl.interval, interval_count: pl.interval_count }
        end
      end
      plans << { plan_id: pl.id, name: pl.name, amount: pl.amount, currency: pl.currency, interval: pl.interval, interval_count: pl.interval_count, installments: all_installments }
    end
    render json: plans, status: 200
  end

  def delete_plan
    response = StripePayment.new(@user).delete_plan(params[:plan_id])
    if response.present?
      @plan.destroy
      render json: { message: "plan deleted successfully!" }, status: 200
    else
      render json: { message: "something went wrong please check parameters" }
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def plan_params # permit plan params
    params.permit(:name, :amount, :currency, :interval, :interval_count, :description)
  end

  def set_plan # instance methode for plan
    @plan = Plan.find_by_id(params[:plan_id])
    if @plan.present?
      return true
    else
      render json: { message: "plan Not found!" }, status: 404
    end
  end

  def is_admin
    if @user.role == "admin"
      true
    else
      render json: { message: "Only admin can create/update/destroy plans!" }
    end
  end
end
