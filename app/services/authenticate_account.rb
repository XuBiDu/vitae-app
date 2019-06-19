# frozen_string_literal: true

require 'http'

module Vitae
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    class NotAuthenticatedError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response =
        HTTP.post("#{@config.API_URL}/auth/authenticate",
                  json: SignedMessage.sign(
                    {
                      username: username,
                      password: password
                    }
                  )
                )

      raise(NotAuthenticatedError) if response.code == 401
      raise if response.code != 200

      data = response.parse

      {
        account: data['attributes']['account'],
        auth_token: data['attributes']['auth_token']
      }
    end
  end
end