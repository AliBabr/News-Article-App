# frozen_string_literal: true

class Api::V1::InstallmentsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_plan, only: %i[create delete_installment]
  before_action :is_admin, only: %i[create delete_installment]

  def create
    response = StripePayment.new(@user).create_plan(params, params[:amount].to_i * 100)
    if response.present?
      installment = Installment.new(installment_params)

      installment.id = response.id
      installment.plan_id = @plan.id
      if installment.save
        render json: { installment_id: installment.id, name: installment.name, amount: installment.amount, currency: installment.currency, interval: installment.interval, interval_count: installment.interval_count }, status: 200
      else
        render json: installment.errors.messages, status: 400
      end
    else
      render json: { message: "Something went wrong please check your parameters all parametrs are compulsory" }
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def delete_installment
    response = StripePayment.new(@user).delete_plan(params[:installment_id])
    if response.present?
      @installment.destroy
      render json: { message: "installment deleted successfully!" }, status: 200
    else
      render json: { message: "something went wrong please check parameters" }
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def installment_params # permit installment params
    params.permit(:name, :amount, :currency, :interval, :interval_count, :description)
  end

  def set_installment # instance methode for installment
    @installment = Installment.find_by_id(params[:installment_id])
    if @installment.present?
      return true
    else
      render json: { message: "installment Not found!" }, status: 404
    end
  end

  def set_plan # instance methode for plan
    @plan = Plan.find_by_id(params[:plan_id])
    if @plan.present?
      return true
    else
      render json: { message: "installment Not found!" }, status: 404
    end
  end

  def is_admin
    if @user.role == "admin"
      true
    else
      render json: { message: "Only admin can create/update/destroy installments!" }
    end
  end
end
