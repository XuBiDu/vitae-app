# frozen_string_literal: true

require 'roda'
require 'slim'

module Vitae
  # Base class for Vitae Web Application
  class App < Roda
    plugin :flash
    plugin :multi_route
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :public, root: 'app/presentation/public'

    route do |routing|
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
