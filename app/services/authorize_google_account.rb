# frozen_string_literal: true

require 'http'

module Vitae
  # Returns an authenticated user, or nil
  class AuthorizeGoogleAccount
    # Errors emanating from Google
    class UnauthorizedError < StandardError
      def message
        'Could not login with Google'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(code)
      tokens = get_tokens_from_google(code)
      get_sso_account_from_api(tokens)
    end

    private

    def get_tokens_from_google(code)
      challenge_response =
        HTTP.post(@config.GOOGLE_TOKEN_ENDPOINT,
                  form: { code: code,
                          client_id: @config.GOOGLE_OAUTH2_CLIENT_ID,
                          client_secret: @config.GOOGLE_OAUTH2_CLIENT_SECRET,
                          redirect_uri: @config.GOOGLE_REDIRECT_URI,
                          grant_type: 'authorization_code'
                           })
      raise UnauthorizedError unless challenge_response.status < 400
      data = challenge_response.parse
      { access_token: data['access_token'], id_token: data['id_token'] }
    end

    def get_sso_account_from_api(tokens)
      response =
        HTTP.post("#{@config.API_URL}/auth/sso",
                  json: tokens)
      raise if response.code > 400

      account_info = response.parse['data']['attributes']

      {
        account: account_info['account'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
