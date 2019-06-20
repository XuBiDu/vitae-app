# frozen_string_literal: true

require_relative '../../config/environments'
require_relative './app'
require 'roda'
require 'rack/ssl-enforcer'
require 'secure_headers'

module Vitae
  # Configuration for the API
  class App < Roda
    plugin :environments
    plugin :multi_route

    FONT_SRC = %w[https://maxcdn.bootstrapcdn.com
                  https://cdnjs.cloudflare.com
                  https://fonts.googleapis.com
                  https://fonts.gstatic.com].freeze
    SCRIPT_SRC = %w[https://code.jquery.com
                    https://maxcdn.bootstrapcdn.com
                    https://cdnjs.cloudflare.com].freeze
    STYLE_SRC = %w[https://maxcdn.bootstrapcdn.com
                   https://cdnjs.cloudflare.com
                   https://fonts.googleapis.com].freeze
    IMG_SRC = %w[https://*.googleusercontent.com].freeze
    FRAME_SRC = %w[https://docs.google.com].freeze
    FORM_SRC = ["#{App.config.API_URL}/download"].freeze

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end

    ## Uncomment to drop the login session in case of any violation
    # use Rack::Protection, reaction: :drop_session

    SecureHeaders::Configuration.default do |config|
      config.cookies = {
        secure: true,
        httponly: true,
        samesite: {
          strict: false
        }
      }

      config.x_frame_options = 'DENY'
      config.x_content_type_options = 'nosniff'
      config.x_xss_protection = '1'
      config.x_permitted_cross_domain_policies = 'none'
      config.referrer_policy = 'origin-when-cross-origin'

      # note: single-quotes needed around 'self' and 'none' in CSPs
      # rubocop:disable Lint/PercentStringArray
      config.csp = {
        report_only: false,
        block_all_mixed_content: true,
        preserve_schemes: true,
        child_src: %w['self'],
        connect_src: %w[wws:],
        default_src: %w['self'],
        img_src: %w['self'] + IMG_SRC,
        font_src: %w['self'] + FONT_SRC,
        form_action: %w['self'] + FORM_SRC,
        frame_ancestors: %w['none'],
        frame_src: %w['self'] + FRAME_SRC,
        object_src: %w['none'],
        script_src: %w['self' 'unsafe-inline'] + SCRIPT_SRC,
        style_src: %W['self' 'unsafe-inline'] + STYLE_SRC,
        report_uri: %w[/security/csp_violation]
      }
      # rubocop:enable Lint/PercentStringArray
    end

    use SecureHeaders::Middleware

    route('security') do |r|
      # POST security/csp_violation
      r.post 'csp_violation' do
        puts "CSP VIOLATION: #{request.body.read}"
      end
    end
  end
end