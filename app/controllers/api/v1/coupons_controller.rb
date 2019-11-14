# frozen_string_literal: true

class Api::V1::CouponsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_plan, only: %i[ delete_coupon]
  before_action :is_admin

  def create
    response = StripePayment.new(@user).create_coupon(params)
    if response.present?
      coupon = Coupon.new(coupon_params)
      coupon.token = response.id
      if coupon.save
        render json: { token: coupon.token, duration: coupon.duration, description: coupon.description, percent_off: coupon.percent_off}, status: 200
      else
        render json: coupon.errors.messages, status: 400
      end
    else
      render json: {message: "Something went wrong please check your parameters all parametrs are compulsory"}
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def index
    coupon = Coupon.all
    coupons = []
    coupon.each do |c|
      coupons<< {token: c.token, duration: c.duration, percent_off: c.percent_off, description: c.description}
    end
    render json: coupons , status: 200
  end

  def delete_coupon
    response = StripePayment.new(@user).delete_coupon(params[:token])
    if response.present?
      @coupon.destroy
      render json: { message: 'coupon deleted successfully!' }, status: 200
    else
      render json: {message: 'something went wrong please check parameters'}
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def coupon_params # permit coupon params
    params.permit(:duration, :token, :percent_off, :description)
  end

  def set_coupon # instance methode for coupon
    @coupon = coupon.find_by_token(params[:token])
    if @coupon.present?
      return true
    else
      render json: { message: 'coupon Not found!' }, status: 404
    end
  end

  def is_admin
    if @user.role == 'admin'
      true
    else
      render json: { message: 'Only admin can create/update/destroy coupons!' }
    end
  end
end



