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

    route do |r|
      @current_account = CurrentSession.new(session).current_account

      r.public
      r.assets
      r.multi_route

      # GET /
      r.root do
        view 'home', locals: { current_account: @current_account }
      end
      r.on 'tos' do
        view 'tos'
      end
      r.on 'privacy' do
        view 'privacy'
      end
    end
  end
end
