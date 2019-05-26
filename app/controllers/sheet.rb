# frozen_string_literal: true

require 'roda'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheet') do |routing|
      routing.on do
        # GET /sheets/
        routing.get String do |sheet_id|
          if @current_account.logged_in?
            view :sheet,
                 locals: { current_user: @current_account, sheet_id: sheet_id }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
