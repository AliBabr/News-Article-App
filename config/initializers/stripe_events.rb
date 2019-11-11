Stripe.api_key = ENV['STRIPE_API_KEY']
StripeEvent.signing_secret = ENV['signing_secret']

StripeEvent.configure do |events|
  events.subscribe 'invoice.', Stripe::InvoiceEventHandler.new
end
