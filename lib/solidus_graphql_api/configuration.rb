# frozen_string_literal: true

module SolidusGraphqlApi
  class Configuration
    attr_accessor :payment_sources

    def initialize
      @payment_sources = ['SolidusGraphqlApi::Types::CreditCard']
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
