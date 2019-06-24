# frozen_string_literal: true

require 'http'

# Returns all account details
class GetAccountDetails
  # Error for accounts that cannot be viewed
  class InvalidAccount < StandardError
    def message
      'You are not authorized to see details of that account'
    end
  end

  def initialize(config)
    @config = config
  end

  def call(current_account, username: nil)
    username = current_account.info.username if username.nil?
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/accounts/#{username}")
    raise InvalidAccount if response.code != 200

    data = response.parse['data']
    account_details = data['attributes']['account']
    auth_token = data['attributes']['auth_token']
    Vitae::Account.new(account_details, auth_token)
  end
end
