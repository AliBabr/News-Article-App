# frozen_string_literal: true
include PUSHNOTIFICATION

class LoginReward
  def initialize(user)
    @user = user
  end

  def reward
    days = (((Time.now - @user.login_time) / 60) / 1440).to_i
    if days <= 7
      Send_Notification('cD28hYQkI0U:APA91bElWoqZTFgckEV1HKN4PbWrMqRlUnTT-A7XHDvFkCjPRfpPSqfcnH8rALLm5qaJeoMN_nYzqKslIJDBZ9jZOUu-gKWbewBxm4h_h5LJB4j-fc0oGupq4dcoWuSCvwZZtlJfqFiM','Congratz', 'You have been awarded with 20 points')
      @user.login_count > 5 ? @user.update(points: @user.points+20, login_count: 0, login_time: Time.now) : @user.update(login_count: @user.login_count + 1)
    else
      @user.update(login_time: Time.now, login_count: 0)
    end
  end
end
