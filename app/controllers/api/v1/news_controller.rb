class Api::V1::NewsController < ApplicationController

  def create
    message = validate()
    if message == 'true'
      news = News.new(news_params)
      if news.save
        image_url = ''
        if news.image.attached?
          image_url = url_for(news.image)
        end
        render json: {title: news.title, website_address: news.website_address, description: news.description, url: news.url, category: news.category, image: image_url }, :status => 200
      else
        render json: news.errors.messages , :status => 400
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def index
    message = validate()
    if message == 'true'
      newss = []
      News.all.each do |ne|
        image_url = ''
        if ne.image.attached?
          image_url = url_for(ne.image)
        end
        newss << { title: ne.title , website_address: ne.website_address, description: ne.description, url: ne.url, category: ne.category, image: image_url}
      end
      render json: newss, status => 200
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def update
    message = validate()
    if message == 'true'
      news = News.find_by_id(params[:id])
      if news.present?
        news.update(news_params)
        if news.errors.any?
          render json: news.errors.messages , :status => 400
        else
          image_url = ''
          if news.image.attached?
            image_url = url_for(news.image)
          end
          render json: {title: news.title, website_address: news.website_address, description: news.description, url: news.url, category: news.category, image: image_url }, :status => 200
        end
      else
        render json: {message: "News Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def destroy
    message = validate()
    if message == 'true'
      news = News.find_by_id(params[:id])
      if news.present?
        news.destroy
        render json: {message: "News deleted successfully!"}, :status => 200
      else
        render json: {message: "News Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def search
    message = validate()
    if message == 'true'
      query = params[:query]
      if query.length < 3
        render json: {message: "Search query length is short!"}, :status => 404
      else
        result = News.search(query)
        newss = []
        result.all.each do |ne|
          image_url = ''
          if ne.image.attached?
            image_url = url_for(ne.image)
          end
          newss << { title: ne.title , website_address: ne.website_address, description: ne.description, url: ne.url, category: ne.category, image: image_url}
        end
        render json: newss, status => 200
      end
    else
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end
  private

  def validate
    user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        return "true"
      else
        return "Unauthorized" + "_" + "401"
      end
    else
      return "User Not Found!" + "_" + "404"
    end
  end

  def news_params
    params.permit(:title, :website_address, :description, :url, :category, :image)
  end

end