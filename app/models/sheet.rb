# frozen_string_literal: true

module Vitae
  # Behaviors of the currently logged in account
  class Sheet
    attr_reader :id, :name, :file_id

    def initialize(sheet_info)
      @id = sheet_info['attributes']['id']
      @file_id = sheet_info['attributes']['file_id']
      @name = sheet_info['attributes']['name']
    end
  end
end
