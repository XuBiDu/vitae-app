# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Vitae::Sheets.map(&:destroy)
  Vitae::Account.map(&:destroy)
end

def authenticate(account_data)
  Vitae::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  {
    account: Vitae::Account.first(username: account['username']),
    scope: AuthScope.new(contents['scope'])
  }
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:sheets] = YAML.safe_load File.read('app/db/seeds/sheets_seed.yml')

