# frozen_string_literal: true

module SolidusGraphqlApi
  module Mutations
    class BaseMutation < GraphQL::Schema::RelayClassicMutation
      argument_class Types::Base::Argument
      field_class Types::Base::Field
      input_object_class Types::Base::InputObject
      object_class Types::Base::Object

      private

      def guest_token
        context[:order_token]
      end

      def current_order
        context[:current_order]
      end

      def current_user
        context[:current_user]
      end

      def current_ability
        context[:current_ability]
      end

      def current_store
        context[:current_store]
      end

      def user_errors(*path, errors)
        return [] if errors.empty?

        errors.map do |error|
          {
            path: ["input", *path].concat(error.attribute.to_s.camelize(:lower).split('.')),
            message: error.message,
          }
        end
      end
    end
  end
end
