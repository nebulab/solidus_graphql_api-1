# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusGraphqlApi::Queries::Variant::DefaultPriceQuery do
  let(:variant) { create(:variant) }

  it { expect(described_class.new(variant: variant).call).to eq(variant.default_price) }
end
