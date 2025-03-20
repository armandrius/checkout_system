# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/checkout_system/models")
loader.setup
loader.eager_load(force: true)

require_relative '../lib/checkout_system/config/initializers/numeric'
require_relative '../lib/checkout_system/config/initializers/money'
