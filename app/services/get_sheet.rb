# frozen_string_literal: true

require 'http'

# Returns all sheets belonging to an account
class GetSheet
  def initialize(config)
    @config = config
  end

  def call(account:, file_id:)
    response = HTTP.auth("Bearer #{account.auth_token}")
                   .get("#{@config.API_URL}/sheet/#{file_id}")

    response.code == 200 ? response.parse['data'] : nil
  end
end
