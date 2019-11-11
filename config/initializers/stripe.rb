Stripe.api_key = "sk_test_OXgdfz0w0U80Ju0B1CBVBk9W"
STRIPE_PUBLIC_KEY = "pk_test_ZNWQ9H8TrCu5RDg3ebtHF2vU"



# #Create card token on stripe
# require 'stripe'
# Stripe.api_key = 'sk_test_OXgdfz0w0U80Ju0B1CBVBk9W'

# Stripe::Token.create({
#   card: {
#     number: '4242424242424242',
#     exp_month: 11,
#     exp_year: 2020,
#     cvc: '314',
#   },
# })
# tok_1FdhT5CjlvBfqWA4aGDx3ic3

# Stripe.api_key = (ENV['STRIPE_API_KEY'])


# #Create customer on stripe
# require 'stripe'
# Stripe.api_key = 'sk_test_OXgdfz0w0U80Ju0B1CBVBk9W'

# response = Stripe::Customer.create({
#   description: 'Customer for jenny.rosen@example.com',
#   email: 'Ali@babar.com',
#   card: 'tok_1Fbvx8CjlvBfqWA4WAVsJ6a'
# })


# #Create subscripion
# require 'stripe'
# Stripe.api_key = 'sk_test_OXgdfz0w0U80Ju0B1CBVBk9W'

# Stripe::Subscription.create({
#   customer: 'cus_G8B9Wj4CIXO9PM',
#   items: [
#     {
#       plan: '1',
#     },
#   ],
# })

#cancel subscription

# require 'stripe'
# Stripe.api_key = 'sk_test_OXgdfz0w0U80Ju0B1CBVBk9W'

# Stripe::Subscription.delete('sub_GA1g7aYMUx3rNc')



# # Cahrge from stripe
# require 'stripe'
# Stripe.api_key = 'sk_test_OXgdfz0w0U80Ju0B1CBVBk9W'
# charge = Stripe::Charge.create({
#   amount: 2000,
#   currency: "usd",
#   source: "tok_1FbZ6kCjlvBfqWA4h0q89PhQ", # obtained with Stripe.js
#   description: "Charge for jenny.rosen@example.com"
# }, {
#   idempotency_key: "g6qE7HCk8GWJTVfB"
# })

