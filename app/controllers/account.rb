# frozen_string_literal: true
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class App < Roda
    route('account') do |r|
      @account_route = '/account'

      r.on do
        # GET /account/
        r.get String do |username|
          account = GetAccountDetails.new(App.config).call(
            @current_account, username
          )
          view :account, locals: { account: account }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          r.redirect '/auth/login'
        rescue StandardError => e
          flash[:error] = 'Internal error -- please try later'
          r.redirect '/'
        end

        # POST /account/<token>
        r.post String do |registration_token|
          passwords = Form::Passwords.call(r.params)

          if passwords.failure?
            flash[:error] = Form.validation_errors(passwords)
            r.redirect "/auth/register/#{registration_token}"
          end

          new_account = SecureMessage.decrypt(registration_token)

          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: r.params['password']
          )
          flash[:notice] = 'Account created, congrats! Please login.'
          r.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          r.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          r.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
