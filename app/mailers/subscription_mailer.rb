class SubscriptionMailer < ApplicationMailer

  default from: "news-article-app@gmail.com"

  def subscribe(user)
    @user = user
    mail to: user.email,  subject: "Subscription"
  end
end
