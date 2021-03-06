# # frozen_string_literal: true

# require 'http'

# module Vitae
#   # Returns an authenticated user, or nil
#   class VerifyRegistration
#     class VerificationError < StandardError; end

#     def initialize(config)
#       @config = config
#     end

#     def call(registration_data)
#       registration_token = SecureMessage.encrypt(registration_data.merge({expires: expires}))
#       registration_data['verification_url'] =
#         "#{@config.APP_URL}/auth/register/#{registration_token}"

#       response = HTTP.post("#{@config.API_URL}/auth/register",
#                            json: SignedRequest.sign(registration_data))
#       raise(VerificationError, response.parse['message']) unless response.code == 202

#       response.parse
#     end

#     def expires
#       Time.now.to_i + @config.REGLINK_EXPIRATION.to_i * 60
#     end
#   end
# end
