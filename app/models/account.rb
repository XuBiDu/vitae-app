# frozen_string_literal: true

module Vitae
  # Behaviors of the currently logged in account
  class Account
    attr_reader :auth_token, :info, :account_info

    def initialize(account_info, auth_token = nil)
      @account_info = account_info
      @info = account_info ? OpenStruct.new(account_info['attributes']) : nil
      @auth_token = auth_token
    end

    def username
      info.email
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end
  end
end
