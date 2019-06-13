# frozen_string_literal: true

require_relative 'base'

module Vitae
  module Form
    NewCV = Dry::Validation.Params do
      configure do
        config.messages_file = File.join(__dir__, 'errors/cv.yml')
      end
      required(:title).value(:filled?)
    end
  end
end
