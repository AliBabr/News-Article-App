
class Api::V1::UsersController < ApplicationController

  # Validates user and send token in response
  def sign_in
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        image_url = ''
        if user.profile_photo.attached?
          image_url = url_for(user.profile_photo)
        end
        render json: {email: user.email, first_name: user.first_name, last_name: user.last_name, phone: user.phone, street_address: user.street_address, city: user.city, state: user.state, zip_code: user.zip_code, profile_photo: image_url , "X-SPUR-USER-ID" => user.uuid, "Authentication-Token" => user.authentication_token }, :status => 200
      else
        render json: {message: "No Email and Password matching that account were found"}, :status => 400
      end
    end
  end


  # Method which accepts credential from user and save data in db
  def sign_up
    user = User.new(email: params[:email], full_name: params[:full_name], password: params[:password])
    user.uuid=SecureRandom.uuid
    if user.save
      render json: {email: user.email, full_name: user.full_name, "X-SPUR-USER-ID" => user.uuid, "Authentication-Token" => user.authentication_token }, :status => 200
    else
      render json: user.errors.messages , :status => 400
    end
  end

  def log_out
    user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token']) && user.update(authentication_token: nil)
        render json: {message: "Logged out successfuly!"}, :status => 200
      else
        render json: {message: "Unauthorized!"}, :status => 401
      end
    else
      render json: {message: "User Not Found!"}, :status => 404
    end
  end

  def update_account
    user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        user.update(user_params)
        if user.errors.any?
          render json: user.errors.messages, :status => 400
        else
          image_url = ''
          if user.profile_photo.attached?
            image_url = url_for(user.profile_photo)
          end
          render json: {email: user.email, first_name: user.first_name, last_name: user.last_name, phone: user.phone, street_address: user.street_address, city: user.city, state: user.state, zip_code: user.zip_code, profile_photo: image_url }, :status => 200
        end
      else
        render json: {message: "Unauthorized!"}, :status => 401
      end
    else
      render json: {message: "User Not found!"}, :status => 404
    end
  end

  def update_password
    user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        if params[:current_password].present?
          if user.valid_password?(params[:current_password])
            user.update(password: params[:new_password])
            if user.errors.any?
              render json: user.errors.messages, :status => 400
            else
              render json: {message: "Password updated successfully!"}, :status => 200
            end
          else
            render json: {message: "Invalid Current Password!"}, :status => 400
          end
        else
          render json: {message: "Password Empty!"}, :status => 400
        end
      else
        render json: {message: "Unauthorized!"}, :status => 401
      end
    else
      render json: {message: "User Not found!"}, :status => 404
    end
  end

  def reset
    @token = params[:tokens]
    @uuid = params[:id]
  end


  def forgot_password
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}, :status => 400
    else
      user = User.where(email: params[:email]).first
      if user.present?
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        token = (0...15).map { o[rand(o.length)] }.join
        UserMailer.forgot_password(user, token).deliver
        user.update(reset_token: token)
        render json: {message: "Please check your Email for reset password!"}, :status => 200
      else
        render json: {message: "Invalid Email!"}, :status => 400
      end
    end
  end

  def reset_password
    @uuid = params[:uuid]
    @token = params[:token]
    @user = User.find_by_uuid(params[:uuid])
    if params[:password] == params[:confirm_password]
      if (params[:token] === @user.reset_token) && (@user.updated_at > DateTime.now-1)
        @user.update(password: params[:password], password_confirmation: params[:confirm_password], reset_token: '')
        if @user.errors.any?
          render 'reset'
        end
      else
        @error = "Token is expired"
        render 'reset'
      end
    else
      @error = "Password and confirm password should match"
      render 'reset'
    end
  end

  private

  def user_params
    params.permit(:email, :first_name, :last_name, :phone, :street_address, :city, :state, :zip_code , :profile_photo)
  end
end