require 'mongoid'
require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'ffaker'
require_relative '../app/app'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.definition_file_paths = %w{./factories ./spec/factories}
  FactoryGirl.find_definitions

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = false
  config.profile_examples = 5
  config.order = :random
  Kernel.srand config.seed
end
