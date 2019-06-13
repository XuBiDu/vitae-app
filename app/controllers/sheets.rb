# frozen_string_literal: true

require 'roda'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheets') do |r|

      @sheets_route = '/sheets'

      r.redirect '/auth/login' unless @current_account.logged_in?

      r.on do
        r.post do
          cv_info = Form::NewCV.call(r.params)
          if cv_info.failure?
            flash[:error] = Form.validation_errors(cv_info)
            r.halt
          end

          NewSheet.new(App.config).call(current_account: @current_account,
                                        cv_info: cv_info)
          flash[:notice] = "New CV created"
          r.redirect @sheets_route
        rescue
          flash[:error] = 'Could not create new CV'
          r.redirect @sheets_route
        ensure
          r.redirect @sheets_route
        end

        r.get do
          sheet_list = GetAllSheets.new(App.config).call(@current_account)
          sheets = Sheets.new(sheet_list)
          view :all_sheets,
                locals: { current_user: @current_account,
                          sheets: sheets
                        }
        # rescue StandardError => e
        #   puts "SHEETS ERROR: #{e.inspect}\n#{e.backtrace}"
        #   flash[:error] = 'Internal error -- please try later'
        #   response.status = 500
        #   r.redirect '/'
        end
      end
    end
  end
end
