# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class App < Roda
    route('account') do |routing|
      @account_route = '/account'

      routing.on do
        # GET /account/
        routing.get String do |username|
          if @current_account && @current_account.username == username
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /account/<token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.call(routing.params)

          if passwords.failure?
            flash[:error] = Form.validation_errors(passwords)
            routing.redirect "/auth/register/#{registration_token}"
          end

          new_account = SecureMessage.decrypt(registration_token)

          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: routing.params['password']
          )
          flash[:notice] = 'Account created, congrats! Please login.'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
