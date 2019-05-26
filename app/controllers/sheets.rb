# frozen_string_literal: true

require 'roda'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheets') do |routing|
      routing.on do
        # GET /sheets/
        routing.get do
          if @current_account.logged_in?
            sheet_list = GetAllSheets.new(App.config).call(@current_account)

            sheets = Sheets.new(sheet_list)

            view :sheets_all,
                 locals: { current_user: @current_account, sheets: sheets }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
