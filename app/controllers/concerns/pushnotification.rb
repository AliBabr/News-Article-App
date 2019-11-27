module PUSHNOTIFICATION
  extend ActiveSupport::Concern

  require 'fcm'

  def Send_Notification(registeration_id, title, body)
    fcm = FCM.new(ENV['FCM_SERVER_KEY'])
    # you can set option parameters in here
    #  - all options are pass to HTTParty method arguments
    #  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L29-L60
    #  fcm = FCM.new("my_server_key", timeout: 3)
    registration_ids= [registeration_id] # an array of one or more client registration tokens

    # See https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages for all available options.
    options = { "notification": {
                  "title": title,
                  "body": body
              }
    }
    response = fcm.send(registration_ids, options)
    parsed_response=JSON.parse(response[:body])
    render json: {errors: parsed_response["failure"], success: parsed_response["success"]}
  end
end