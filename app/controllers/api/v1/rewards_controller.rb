# frozen_string_literal: true

class Api::V1::RewardsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_reward, only: %i[update destroy show]
  before_action :is_admin, only: %i[create update destroy]

  #Methode to create reward
  def create
    reward = Reward.new(reward_params); image_url = ''
    if reward.save
      image_url = url_for(reward.image) if reward.image.attached?
      render json: { id: reward.id, title: reward.title, description: reward.description, latitude: reward.latitude, logitude: reward.longitude, address: reward.address, category: reward.category, shop_name: reward.shop_name, image: image_url }, status: 200
    else
      render json: reward.errors.messages, status: 400
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #methode to get all rewards
  def index
    rewards = []; image_url = ''
    Reward.all.each do |reward|
      image_url = url_for(reward.image) if reward.image.attached?
      rewards << { id: reward.id, title: reward.title, image: image_url }
    end
    render json: rewards, status => 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #methode to update reward
  def update
    @reward.update(reward_params); image_url = ''
    if @reward.errors.any?
      render json: @reward.errors.messages, status: 400
    else
      image_url = url_for(@reward.image) if @reward.image.attached?
      render json: { id: @reward.id, title: @reward.title, description: @reward.description, latitude: @reward.latitude, logitude: @reward.longitude, address: @reward.address, category: @reward.category, shop_name: @reward.shop_name, image: image_url }, status: 200
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to delete reward
  def destroy
    @reward.destroy
    render json: { message: 'reward deleted successfully!' }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to get all infor about specific reward
  def show
    image_url = ''
    image_url = url_for(@reward.image) if @reward.image.attached?
    render json: { id: @reward.id, title: @reward.title, description: @reward.description, latitude: @reward.latitude, logitude: @reward.longitude, address: @reward.address, shop_name: @reward.shop_name, image: image_url }, status: 200
  end

  #Methode to redeem user points
  def redeem
    if params[:reward_id].present? && Reward.find_by_id(params[:reward_id].to_i).present?
      reward = Reward.find_by_id(params[:reward_id])
      status = Redeemption.new(reward.category, @user).redeem
      if status == true
        RedemptionMailer.call(@user, @user.email, reward,  "").deliver
        render json: { message: 'Your points has been redeemed' }, status => 200
      else
        render json: { message: 'Your points are less for this reward, commplete daily challenges and try again' }, status: 404
      end
    else
      render json: { message: 'Please provide valid reward id' }, status => 401
    end
  end

  def ship_to_me_redemption
    if params[:shipping_address].present? && params[:reward_id].present? && Reward.find_by_id(params[:reward_id].to_i)
      reward = Reward.find_by_id(params[:reward_id])
      status = Redeemption.new(reward.category, @user).redeem
      if status == true
        RedemptionMailer.call(@user, @user.email, reward,  "").deliver
        RedemptionMailer.call(@user, "astropowerbox@gmail.com", reward,  params[:shipping_address]).deliver
        render json: { message: 'Your points has been redeemed' }, status => 200
      else
        render json: { message: 'Your points are less for this reward, commplete daily challenges and try again' }, status: 404
      end
    else
      render json: { message: 'Please check something is incorrect or missing all parameters all compulsory' }, status => 401
    end
  end

  #methode to get all user points
  def points
    render json: { points: @user.points }, status => 200
  end

  private
 
  def reward_params # permit  reward params
    params.permit(:title, :address, :description, :latitude, :longitude, :category, :shop_name, :image)
  end
 
  def set_reward #instance methode for reward
    @reward = Reward.find_by_id(params[:id])
    if @reward.present?
      return true
    else
      render json: { message: 'reward Not found!' }, status: 404
    end
  end

  def is_admin
    if @user.role == 'admin'
      return true
    else
      render json: { message: "Only admin can create/update/destroy rewards!"}
    end
  end

end
