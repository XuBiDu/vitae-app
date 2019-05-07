# frozen_string_literal: true

require './require_app'
require_app

run Vitae::App.freeze.app
