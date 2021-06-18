# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

# Run Coverage report
require 'solidus_dev_support/rspec/coverage'

# Create the dummy app if it's still missing.
dummy_env = "#{__dir__}/dummy/config/environment.rb"
system 'bin/rake extension:test_app' unless File.exist? dummy_env
require dummy_env

# Requires factories and other useful helpers defined in spree_core.
require 'solidus_dev_support/rspec/feature_helper'
require "graphql/schema_comparator"
require 'with_model'
require 'timecop'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Requires factories defined in lib/solidus_graphql_api/testing_support/factories.rb
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusGraphqlApi::Engine)

RSpec.configure do |config|
  config.add_setting :default_freeze_date, default: "21/12/2012 12:00:00"
  config.add_setting :graphql_queries_dir, default: "spec/support/graphql/queries"
  config.add_setting :graphql_mutations_dir, default: "spec/support/graphql/mutations"
  config.add_setting :graphql_responses_dir, default: "spec/support/graphql/responses"

  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  if defined?(ActiveStorage::Current)
    config.before(:all) do
      ActiveStorage::Current.host = 'https://www.example.com'
    end
  end


  config.include Helpers::Graphql
  config.include Matchers::Graphql

  # They can be used in the specs to explain better the result of a Graphql query.
  config.alias_example_group_to :describe_query, type: :graphql_query
  config.alias_example_group_to :connection_field, type: :graphql_query
  config.alias_example_group_to :field, type: :graphql_query
  config.alias_example_group_to :describe_mutation, type: :graphql_mutation

  config.before(:each) do
    BatchLoader::Executor.clear_current
  end

  config.around(:each, type: :graphql_query) do |example|
    freeze_date = example.metadata[:freeze_date]

    if freeze_date
      Timecop.freeze(DateTime.parse(freeze_date.is_a?(String) ? freeze_date : RSpec.configuration.default_freeze_date))
      example.run
      Timecop.return
    else
      example.run
    end
  end

  config.extend WithModel
end
