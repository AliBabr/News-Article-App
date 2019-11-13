class UpgradeSubscriptionMailer < ApplicationMailer
  default from: "news-article-app@gmail.com"

  def upgrade(user, subscription)
    @user = user
    @subscription = subscription
    mail to: user.email,  subject: "Subscription upgraded"
  end
end
