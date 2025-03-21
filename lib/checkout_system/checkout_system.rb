# frozen_string_literal: true

require 'zeitwerk'
require_relative 'config/initializers/numeric'
require_relative 'config/initializers/money'
require_relative 'shop_app'

module CheckoutSystem
  loader = Zeitwerk::Loader.new
  loader.push_dir("#{__dir__}/models")
  loader.push_dir("#{__dir__}/views")
  loader.setup
  loader.eager_load(force: true)
end
