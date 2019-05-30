# frozen_string_literal: true

require 'http'

# Returns all sheets belonging to an account
class NewSheet
  class CannotCreateError < StandardError; end

  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post("#{@config.API_URL}/sheets")

    raise(CannotCreateError) unless response.code == 201
  end
end
