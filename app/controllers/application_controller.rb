class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  def authenticate
    @user = User.find_by_id(request.headers["X_NEWS_ARTICLE_USER_ID"])
    if @user.present?
      if User.validate_token(request.headers["X_NEWS_ARTICLE_USER_ID"], request.headers["Authentication_Token"])
        return true
      else
        render json: { message: "Unauthorized!" }, status: 401
      end
    else
      render json: { message: "User Not Found!" }, status: 404
    end
  end
end
