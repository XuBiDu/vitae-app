# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password'])

          session[:current_account] = account
          flash[:notice] = "Welcome back #{account['username']}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash[:error] = 'Username and password did not match our records'
          routing.redirect @login_route
        rescue StandardError
          flash[:error] = 'Internal error, please try again later'
          routing.redirect @login_route
        end
      end

      routing.on 'logout' do
        routing.get do
          session[:current_account] = nil
          routing.redirect @login_route
        end
      end
    end
  end
end
