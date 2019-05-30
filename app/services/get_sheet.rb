# frozen_string_literal: true

require 'http'

# Returns all sheets belonging to an account
class GetSheet
  def initialize(config)
    @config = config
  end

  def call(current_account, file_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/sheet/#{file_id}/view")

    response.code == 200 ? response.parse['data'] : nil
  end
end
