# frozen_string_literal: true

class LoginReward
  def initialize(user)
    @user = user
  end

  def reward
    days = (((Time.now - @user.login_time) / 60) / 1440).to_i
    if days <= 7
      @user.login_count > 5 ? @user.update(points: @user.points+20, login_count: 0, login_time: Time.now) : @user.update(login_count: @user.login_count + 1)
    else
      @user.update(login_time: Time.now, login_count: 0)
    end
  end
end
