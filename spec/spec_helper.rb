# frozen_string_literal: true

require 'factory_bot'
require_relative '../lib/checkout_system/checkout_system'

RSpec.configure do |config|
  config.before(:suite) do
    FactoryBot.definition_file_paths = [
      File.expand_path('factories', __dir__)
    ]
    FactoryBot.find_definitions
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods
end
