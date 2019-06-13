# frozen_string_literal: true

require_relative 'base'

module Vitae
  module Form
    CollabEmail = Dry::Validation.Params do
      configure do
        config.messages_file = File.join(__dir__, 'errors/account.yml')
      end

      required(:email).filled(format?: EMAIL_REGEX)
    end
  end
end
