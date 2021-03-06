# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'rack/ssl-enforcer'
require 'rack/session/redis'
require_relative '../require_app'

module Vitae
  # Configuration for the API
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'
    ONE_DAY = 24 * 60 * 60
    ONE_MONTH = 30 * ONE_DAY

    ENV['GOOGLE_ACCOUNT_TYPE'] = config['GOOGLE_ACCOUNT_TYPE']
    ENV['GOOGLE_CLIENT_ID'] = config['GOOGLE_CLIENT_ID']
    ENV['GOOGLE_CLIENT_EMAIL'] = config['GOOGLE_CLIENT_EMAIL']
    ENV['GOOGLE_PRIVATE_KEY'] = config['GOOGLE_PRIVATE_KEY']

    configure do
      SecureSession.setup(config)
      SecureMessage.setup(config)
      SignedMessage.setup(config)
    end

    use Rack::Session::Redis,
          expire_after: ONE_MONTH, redis_server: config.REDIS_URL

    configure :development, :test do

      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end
  end
end
