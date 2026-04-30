# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/config/"

    track_files "{app,lib}/**/*.rb"

    minimum_coverage 80
  end
end

require "hello"
require "factory_bot"
require "hello"

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = :expect
  end

  # FactoryBot definition directory
  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
