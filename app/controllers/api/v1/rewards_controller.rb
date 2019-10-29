class Api::V1::RewardsController < ApplicationController

  def create
    message = validate()
    if message == 'true'
      reward = Reward.new(reward_params)
      if reward.save
        image_url = ''
        if reward.image.attached?
          image_url = url_for(reward.image)
        end
        render json: {id: reward.id, title: reward.title, description: reward.description, latitude: reward.latitude, logitude: reward.longitude , address: reward.address, category: reward.category, shop_name: reward.shop_name, image: image_url }, :status => 200
      else
        render json: reward.errors.messages , :status => 400
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def index
    message = validate()
    if message == 'true'
      rewards = []
      Reward.all.each do |reward|
        image_url = ''
        if reward.image.attached?
          image_url = url_for(reward.image)
        end
        rewards << {id: reward.id,  title: reward.title , image: image_url}
      end
      render json: rewards, status => 200
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def update
    message = validate()
    if message == 'true'
      reward = Reward.find_by_id(params[:id])
      if reward.present?
        reward.update(reward_params)
        if reward.errors.any?
          render json: reward.errors.messages , :status => 400
        else
          image_url = ''
          if reward.image.attached?
            image_url = url_for(reward.image)
          end
          render json: {id: reward.id, title: reward.title, description: reward.description, latitude: reward.latitude, logitude: reward.longitude , address: reward.address, category: reward.category, shop_name: reward.shop_name, image: image_url }, :status => 200
        end
      else
        render json: {message: "reward Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def destroy
    message = validate()
    if message == 'true'
      reward = Reward.find_by_id(params[:id])
      if reward.present?
        reward.destroy
        render json: {message: "reward deleted successfully!"}, :status => 200
      else
        render json: {message: "reward Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end


  def show
    message = validate()
    if message == 'true'
      reward = Reward.find_by_id(params[:id])
      if reward.present?
        image_url = ''
        if reward.image.attached?
          image_url = url_for(reward.image)
        end
        render json: {reward_id: reward.id ,title: reward.title, description: reward.description, latitude: reward.latitude, logitude: reward.longitude , address: reward.address, shop_name: reward.shop_name,  image: image_url }, :status => 200
      else
        render json: {message: "reward Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def redeem
    message = validate()
    if message == 'true'
      category = params[:category].to_i
      if category == 1
        if @user.points > 500
          @user.update(points: @user.points - 500)
          render json: {message: 'Your points has been redeemed'}, status => 200
        else
          render json: {message: "Your points are less for this reward, commplete daily challenges and try again"}, :status => 404
        end
      elsif category == 2
        if @user.points > 1000
          @user.update(points: @user.points - 1000)
          render json: {message: 'Your points has been redeemed'}, status => 200
        else
          render json: {message: "Your points are less for this reward, commplete daily challenges and try again"}, :status => 404
        end
      elsif category == 3
        if @user.points > 5000
          @user.update(points: @user.points - 5000)
          render json: {message: 'Your points has been redeemed'}, status => 200
        else
          render json: {message: "Your points are less for this reward, commplete daily challenges and try again"}, :status => 404
        end
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def points
    message = validate()
    if message == 'true'
      render json: {points: @user.points}, status => 200
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  private

  def validate
    @user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if @user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        return "true"
      else
        return "Unauthorized" + "_" + "401"
      end
    else
      return "User Not Found!" + "_" + "404"
    end
  end

  def reward_params
    params.permit(:title, :address, :description, :latitude, :longitude , :category, :shop_name, :image)
  end

end