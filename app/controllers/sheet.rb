# frozen_string_literal: true

require 'roda'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheet') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      routing.on String do |sheet_id|
        routing.is 'edit', method: :get do
        # GET /sheets/
            view :sheet,
                locals: { current_user: @current_account, sheet_id: sheet_id }
        end
        routing.is 'view', method: :get do
          # GET /sheets/
          sheet = GetSheet.new(App.config).call(@current_account, sheet_id)
          view :sheet,
                locals: { current_user: @current_account, sheet_id: sheet }
        end
      end
    end
  end
end
