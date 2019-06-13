# frozen_string_literal: true

require 'http'

# Returns all sheets belonging to an account
class NewSheet
  class CannotCreateError < StandardError; end

  def initialize(config)
    @config = config
  end

  def call(current_account:, cv_info:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post("#{@config.API_URL}/sheets",
                    json: { title: cv_info[:title] })

    # raise CannotCreateError unless response.code == 201
  end
end
