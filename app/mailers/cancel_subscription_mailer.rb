class CancelSubscriptionMailer < ApplicationMailer

  default from: "news-article-app@gmail.com"

  def cancel_subscription(user)
    @user = user
    mail to: user.email,  subject: "Cancel Subscription"
  end
end
