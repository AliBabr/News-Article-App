class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  def authenticate
    @user = User.find_by_id(request.headers["UUID"])
    if @user.present?
      if User.validate_token(request.headers["UUID"], request.headers["Authentication"])
        return true
      else
        render json: { message: "Unauthorized!" }, status: 401
      end
    else
      render json: { message: "User Not Found!" }, status: 404
    end
  end
end
