# frozen_string_literal: true

module SolidusGraphqlApi
  module Types
    class Address < Base::RelayNode
      description 'Address.'

      field :address1, String, null: false
      field :address2, String, null: true
      field :alternative_phone, String, null: true
      field :city, String, null: false
      field :company, String, null: true
      field :country, Country, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: true
      field :name, String, null: false
      field :phone, String, null: false
      field :state_name, String, null: true
      field :state, State, null: true
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
      field :zipcode, String, null: false

      def state
        Queries::Address::StateQuery.new(address: object).call
      end

      def country
        Queries::Address::CountryQuery.new(address: object).call
      end
    end
  end
end
