# frozen_string_literal: true

module Stripe
  class InvoiceEventHandler
    def call(event)
      method = 'handle_' + event.type.tr('.', '_')
      send method, event
    rescue JSON::ParserError => e
      # handle the json parsing error here
      raise # re-raise the exception to return a 500 error to stripe
    rescue NoMethodError => e
      # code to run when handling an unknown event
    end

    def handle_invoice_payment_failed(_event)
    end

    def handle_invoice_payment_succeeded(_event)
    end

    def handle_invoice_payment_created(_event)
    end
  end
end
