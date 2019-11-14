# frozen_string_literal: true
Stripe.api_key = ENV['STRIPE_API_KEY']

class StripePayment
  def initialize(user)
    @user = user
  end

  def create_customer(card_token)
    customer = Stripe::Customer.create({
      description: "News Article App new customer",
      email: @user.email,
      card: card_token
    })
    if customer.id.present?
      @user.update(stripe_cutomer_id: customer.id)
      return true
    else
      return false
    end
  end

  def create_plan(params, amount)
    plan = Stripe::Plan.create({
      amount: amount,
      currency: params[:currency],
      interval: params[:interval],
      interval_count: params[:interval_count],
      product: {name: params[:name]},
    })
    if plan.id.present?
      return plan
    else
      return nil
    end
  end

  def delete_plan(plan_id)
    plan = Stripe::Plan.delete(plan_id)
    if plan.id.present?
      return true
    else
      return false
    end
  end

  def create_coupon(params)
    coupon = Stripe::Coupon.create({
      duration: params[:duration],
      id: params[:token],
      percent_off: params[:percent_off],
    })
    if coupon.id.present?
      return coupon
    else
      return false
    end
  end

  def delete_coupon(coupon_id)
    coupon = Stripe::Coupon.delete(
      coupon_id,
    )
    if coupon.id.present?
      return true
    else
      return false
    end
  end

  def create_subscription(plan_id)
    delete_subscription()
    subscription = Stripe::Subscription.create({
      customer: @user.stripe_cutomer_id,
      items: [
        {
          plan: plan_id,
        },
      ],
    })
    if subscription.id.present?
      return subscription
    else
      return nil
    end
  end

  def delete_subscription
    subscription = @user.subscriptions.where(status: 'active')
    Stripe::Subscription.delete(subscription.first.subscription_tok) if subscription.present? && subscription.first.subscription_tok.present?
    subscription.update(subscription_tok: nil)
    return true
  end
end
