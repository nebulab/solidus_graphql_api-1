# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusGraphqlApi
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_graphql_api'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.autoload_paths << File.expand_path('..', __dir__)

    initializer "solidus_graphql_api.setup_batch_loader_middleware" do |app|
      app.middleware.use BatchLoader::Middleware
    end
  end
end
