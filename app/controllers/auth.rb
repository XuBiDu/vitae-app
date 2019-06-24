# frozen_string_literal: true

require 'roda'
require_relative './app'
require 'econfig'

module Vitae
  # Auth controller for Vitae API
  class App < Roda
    def google_oauth2_url(config)
      url = config.GOOGLE_OAUTH2_ENDPOINT
      client_id = config.GOOGLE_OAUTH2_CLIENT_ID
      redirect_uri = CGI.escape(config.GOOGLE_REDIRECT_URI)
      response_type = 'code'
      scope = CGI::escape(config.GOOGLE_SCOPE)
      "#{url}?client_id=#{client_id}&scope=#{scope}&response_type=#{response_type}&redirect_uri=#{redirect_uri}"
    end

    route('auth') do |r| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      r.is 'login' do
        # GET /auth/login
        r.get do
          r.redirect google_oauth2_url(App.config)
        end

        # # POST /auth/login
        # r.post do
        #   credentials = Form::LoginCredentials.call(r.params)

        #   if credentials.failure?
        #     flash[:error] = 'Please enter both username and password'
        #     r.redirect @login_route
        #   end

        #   authenticated = AuthenticateAccount.new(App.config).call(credentials)
        #   current_account = Account.new(
        #     authenticated[:account],
        #     authenticated[:auth_token]
        #   )

        #   CurrentSession.new(session).current_account = current_account

        #   flash[:notice] = "Welcome back #{current_account.username}!"
        #   r.redirect '/'
        # rescue AuthenticateAccount::UnauthorizedError
        #   flash[:error] = 'Username and/or password do not match our records'
        #   response.status = 403
        #   r.redirect @login_route
        # rescue StandardError => e
        #   puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
        #   flash[:error] = 'Internal error -- please try later'
        #   response.status = 500
        #   r.redirect @login_route
        # end
      end

      r.is 'google_callback' do
        # GET /auth/google_callback
        r.get do
          authorized = AuthorizeGoogleAccount
                       .new(App.config)
                       .call(r.params['code'])


          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.info.given_name}!"
          r.redirect '/sheets'
        rescue AuthorizeGoogleAccount::UnauthorizedError
          flash[:error] = 'Could not login with Google'
          response.status = 403
          r.redirect @login_route
        rescue StandardError => e
          puts "GOOGLE SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          r.redirect @login_route
        end
      end

      # GET /auth/logout
      @logout_route = '/auth/logout'
      r.is 'logout' do
        r.get do
          CurrentSession.new(session).delete
          flash[:notice] = 'You are now logged out.'
          r.redirect '/'
        end
      end

      @register_route = '/auth/register'
      # r.on 'register' do
      #   r.is do
      #     # GET /auth/register
      #     r.get do
      #       view :register
      #     end

      #     r.post do
      #       registration = Form::Registration.call(r.params)

      #       if registration.failure?
      #         flash[:error] = Form.validation_errors(registration)
      #         r.redirect @register_route
      #       end

      #       a = VerifyRegistration.new(App.config).call(registration.output)
      #       flash[:notice] = 'Please check your email for a verification link'
      #       r.redirect '/'
      #     rescue StandardError => e
      #       puts "ERROR VERIFYING REGISTRATION: #{r.params}\n#{e.inspect}"
      #       flash[:error] = e.message
      #       r.redirect @register_route
      #     end

      #     # POST /auth/register
      #     r.post do
      #       account_data = JsonRequestBody.symbolize(r.params)
      #       VerifyRegistration.new(App.config).call(account_data)

      #       flash[:notice] = "Check your email and click the verification link. The link expires in #{App.config.REGLINK_EXPIRATION} minutes."
      #       r.redirect '/'
      #     rescue StandardError => e
      #       puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
      #       flash[:error] = 'Registration details are not valid'
      #       r.redirect @register_route
      #     end
      #   end

      #   # GET /auth/register/<token>
      #   r.get(String) do |registration_token|
      #     begin
      #       new_account = SecureMessage.decrypt(registration_token)
      #     rescue StandardError => e
      #       puts "ERROR WITH REGISTRATION TOKEN: #{e.inspect}"
      #       flash[:error] = 'Internal error'
      #       r.redirect @register_route
      #     end
      #     if Time.now.to_i > new_account['expires']
      #       flash[:error] = 'Link expired. Please register again.'
      #       r.redirect @register_route
      #     end

      #     flash.now[:notice] = 'Email Verified! Please choose a new password'
      #     view :register_confirm,
      #          locals: { new_account: new_account,
      #                    registration_token: registration_token }
      #   end
      # end
    end
  end
end
