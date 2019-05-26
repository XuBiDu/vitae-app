require_relative 'sheet'

module Vitae
  # Behaviors of the currently logged in account
  class Sheets
    attr_reader :all

    def initialize(sheets_list)
      @all = sheets_list.map do |sheet|
        Sheet.new(sheet)
      end
    end
  end
end
