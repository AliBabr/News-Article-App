# frozen_string_literal: true

# app/services/GooglePlaces.rb
class Redeemption
  def initialize(category, user)
    @user = user
    @category = category
  end

  def redeem
    if @category == 1
      if @user.points >= 500
        @user.update(points: @user.points - 500)
        return true
      else
        return false
      end
    elsif @category == 2
      if @user.points >= 1000
        @user.update(points: @user.points - 1000)
        return true
      else
        return false
      end
    elsif @category == 3
      if @user.points >= 5000
        @user.update(points: @user.points - 5000)
        return true
      else
        return false
      end
    end
  end


end
