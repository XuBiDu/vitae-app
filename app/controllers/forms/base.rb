# frozen_string_literal: true

require 'dry-validation'

module Vitae
  # Form helpers
  module Form
    USERNAME_REGEX = /^[a-z0-9]([._]?[a-z0-9]+)*$/i.freeze
    EMAIL_REGEX = /.+@.+/.freeze

    def self.validation_errors(validation)
      validation.errors.map { |k, v| [k, v].join(': ') }
    end

    def self.message_values(validation)
      validation.messages.values.join('; ')
    end
  end
end
