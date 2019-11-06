
class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: %i[update_account update_password log_out save_stripe_token] # call back for validating user
  before_action :forgot_validation, only: [:forgot_password]
  before_action :before_reset, only: [:reset_password]

  # Validates user and send token in response
  def sign_in
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        LoginReward.new(user).reward
        render json: { email: user.email, first_name: user.first_name, last_name: user.last_name, 'X-NEWS-ARTICLE-USER-ID' => user.id, 'Authentication-Token' => user.authentication_token }, status: 200
      else
        render json: { message: 'No Email and Password matching that account were found' }, status: 400
      end
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end


  # Method which accepts credential from user and save data in db
  def sign_up
    user = User.new(email: params[:email], full_name: params[:full_name], password: params[:password], login_count: 0, login_time: Time.now); user.id = SecureRandom.uuid; user.points = 0 # genrating secure uuid token
    if user.save
      render json: {email: user.email, full_name: user.full_name, "X-NEWS-ARTICLE-USER-ID" => user.id, "Authentication-Token" => user.authentication_token }, :status => 200
    else
      render json: user.errors.messages, status: 400
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end


   # Methode that expire user session
  def log_out
    @user.update(authentication_token: nil)
    render json: { message: 'Logged out successfuly!' }, status: 200
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def update_account
    @user.full_name = params[:first_name] + " " + params[:last_name]
    @user.update(user_params); image_url = '';
    if @user.errors.any?
      render json: @user.errors.messages, :status => 400
    else
      image_url = url_for(@user.profile_photo) if @user.profile_photo.attached?
      render json: {email: @user.email, first_name: @user.first_name, last_name: @user.last_name, phone: @user.phone, street_address: @user.street_address, city: @user.city, state: @user.state, zip_code: @user.zip_code, profile_photo: image_url }, :status => 200
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def update_password
    if params[:current_password].present? && @user.valid_password?(params[:current_password])
      @user.update(password: params[:new_password])
      if @user.errors.any?
        render json: @user.errors.messages, status: 400
      else
        render json: { message: 'Password updated successfully!' }, status: 200
      end
    else
      render json: { message: 'Current Password is not present or invalid!' }, status: 400
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode that render reset password form
  def reset
    @token = params[:tokens]
    @id = params[:id]
  end

  # Methode that send email while user forgot password
  def forgot_password
    UserMailer.forgot_password(@user, @token).deliver
    @user.update(reset_token: @token)
    render json: { message: 'Please check your Email for reset password!' }, status: 200
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode that take new password and cunform password and reset user password
  def reset_password
    if (params[:token] === @user.reset_token) && (@user.updated_at > DateTime.now - 1)
      @user.update(password: params[:password], password_confirmation: params[:confirm_password], reset_token: '')
      render 'reset' if @user.errors.any?
    else
      @error = 'Token is expired'; render 'reset'
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to create customer against stripe card token
  def save_stripe_token
    if params[:card_token].present?
      response = Stripe.new(@user).create_customer(params[:card_token])
      if response
        render json: {message: "Token saved successfully!"}, status: 200
      else
        render json: {message: "Invalid Token!"}, status: 401
      end
    else
      render json: {message: "Please provide card token"}
    end
  end

  private

  def user_params
    params.permit(:email, :first_name, :last_name, :phone, :street_address, :city, :state, :zip_code , :profile_photo)
  end


  # Helper methode for forgot password methode
  def forgot_validation
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }, status: 400
    else
      @user = User.where(email: params[:email]).first
      if @user.present?
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten; @token = (0...15).map { o[rand(o.length)] }.join;
      else
        render json: { message: 'Invalid Email!' }, status: 400
      end
    end
  end

  # Helper methode for reset password methode
  def before_reset
    @id = params[:id]; @token = params[:token]; @user = User.find_by_id(params[:id])
    if params[:password] == params[:confirm_password]
      return true
    else
      @error = 'Password and confirm password should match'
      render 'reset'
    end
  end
end