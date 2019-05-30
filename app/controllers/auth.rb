# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Auth controller for Vitae API
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new(App.config).call(credentials)


          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash[:error] = 'Username and/or password do not match our records'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Internal error -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # GET /auth/logout
      @logout_route = '/auth/logout'
      routing.is 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = "You are now logged out."
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          routing.post do
            registration = Form::Registration.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            a = VerifyRegistration.new(App.config).call(registration.output)
            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError => e
            puts "ERROR VERIFYING REGISTRATION: #{routing.params}\n#{e.inspect}"
            flash[:error] = e.message
            routing.redirect @register_route
          end

          # POST /auth/register
          routing.post do
            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = "Check your email and click the verification link. The link expires in #{App.config.REGLINK_EXPIRATION} minutes."
            routing.redirect '/'
          rescue StandardError => e
            puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
            flash[:error] = 'Registration details are not valid'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          begin
            new_account = SecureMessage.decrypt(registration_token)
          rescue StandardError => e
            puts "ERROR WITH REGISTRATION TOKEN: #{e.inspect}"
            flash[:error] = 'Internal error'
            routing.redirect @register_route
          end
          if Time.now.to_i > new_account['expires']
            flash[:error] = 'Link expired. Please register again.'
            routing.redirect @register_route
          end

          flash.now[:notice] = 'Email Verified! Please choose a new password'
          view :register_confirm,
               locals: { new_account: new_account,
                         registration_token: registration_token }
        end
      end
    end
  end
end
