# frozen_string_literal: true

module SolidusGraphqlApi
  module Queries
    module Variant
      class DefaultPriceQuery
        attr_reader :variant

        def initialize(variant:)
          @variant = variant
        end

        def call
          variant.default_price
        end
      end
    end
  end
end
