# frozen_string_literal: true

require 'solidus_dev_support/rake_tasks'
require 'graphql-docs'

SolidusDevSupport::RakeTasks.install

task default: 'extension:specs'

namespace :schema do
  desc 'Generates documentation from schema.graphql'
  task :generate_docs do
    doc_dir = "./lib/graphql_docs"
    GraphQLDocs.build(
      filename: "#{__dir__}/schema.graphql",
      output_dir: 'docs',
      base_url: '/solidus_graphql_api/docs',
      landing_pages: { index: "#{doc_dir}/landing_pages/index.md" },
      delete_output: true
    )
  end

  desc 'Dump the schema to JSON and IDL and generate docs'
  task :dump do
    setup_graphql_rake_tasks

    Rake::Task['graphql:schema:dump'].invoke
    Rake::Task['schema:generate_docs'].invoke
  end

  desc 'Dump the schema to IDL in schema.graphql and generate docs'
  task :idl do
    setup_graphql_rake_tasks

    Rake::Task['graphql:schema:idl'].invoke
    Rake::Task['schema:generate_docs'].invoke
  end

  desc 'Dump the schema to JSON in schema.json and generate docs'
  task :json do
    setup_graphql_rake_tasks

    Rake::Task['graphql:schema:json'].invoke
    Rake::Task['schema:generate_docs'].invoke
  end
end

private

def setup_graphql_rake_tasks
  require 'graphql/rake_task'
  GraphQL::RakeTask.new(schema_name: 'SolidusGraphqlApi::Schema')

  Rake::Task['extension:test_app'].invoke if Dir['spec/dummy'].empty?

  require File.expand_path('spec/dummy/config/environment.rb', __dir__)
end
