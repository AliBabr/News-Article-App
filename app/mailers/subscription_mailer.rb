class SubscriptionMailer < ApplicationMailer

  default from: "news-article-app@gmail.com"

  def subscribe(user, subscription)
    @user = user
    @subscription = subscription
    mail to: user.email,  subject: "Subscription"
  end
end
