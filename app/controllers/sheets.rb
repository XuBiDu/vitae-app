# frozen_string_literal: true

require 'roda'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheets') do |routing|

      routing.redirect '/auth/login' unless @current_account.logged_in?

      routing.on do
        routing.post do
          NewSheet.new(App.config).call(@current_account)
          flash[:notice] = "New CV created"
          routing.redirect '/sheets'
        rescue
          flash[:error] = 'Could not create new CV'
          routing.redirect '/sheets'
        end

        routing.get do
          sheet_list = GetAllSheets.new(App.config).call(@current_account)
          sheets = Sheets.new(sheet_list)
          view :sheets_all,
                locals: { current_user: @current_account, sheets: sheets }
        # rescue StandardError => e
        #   puts "SHEETS ERROR: #{e.inspect}\n#{e.backtrace}"
        #   flash[:error] = 'Internal error -- please try later'
        #   response.status = 500
        #   routing.redirect '/'
        end
      end
    end
  end
end
