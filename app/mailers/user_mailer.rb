class UserMailer < ApplicationMailer
  default from: "system@gmail.com"

  def forgot_password(user, token)
    @user = user
    @token = token
    @url = reset_api_v1_user_url(@user.id, tokens: token)
    mail to: user.email, subject: "Forgot passowrd"
  end
end
