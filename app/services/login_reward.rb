# frozen_string_literal: true

class LoginReward
  def initialize(user)
    @user = user
  end

  def reward
    days = (((Time.now - @user.login_time) / 60) / 1440).to_i
    if days <= 7
      if @user.login_count > 5
        PushNotification.new(@user.device_token, 'Congrats', 'You have been awarded with 20 points').Send_Notification
        @user.update(points: @user.points+20, login_count: 0, login_time: Time.now)
      else
        @user.update(login_count: @user.login_count + 1)
      end
    else
      @user.update(login_time: Time.now, login_count: 0)
    end
  end
end
