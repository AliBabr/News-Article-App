# frozen_string_literal: true

class RedemptionMailer < ApplicationMailer
  default from: 'news-article-app@gmail.com'

  # def call(user, email, reward, shipping_address)
  def call(user, email, reward, shipping_address)
    @user = user
    @reward = reward
    # admin = "astropowerbox@gmail.com"
    admin = "news.article.sysetm@gmail.com"
    @shipping_address = shipping_address
    mail to: email, subject: 'Redemption details'
  end

end
