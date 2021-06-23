# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusGraphqlApi::Types::Product do
  let(:product) { create(:product) }
  let(:query_object) { spy(:query_object) }

  subject { described_class.send(:new, product, {}) }

  describe '#master_variant' do
    before do
      allow(SolidusGraphqlApi::Queries::Product::MasterVariantQuery).to receive(:new).and_return(query_object)
    end

    after { subject.master_variant }

    it { expect(SolidusGraphqlApi::Queries::Product::MasterVariantQuery).to receive(:new).with(product: product) }

    it { expect(query_object).to receive(:call) }
  end

  describe '#option_types' do
    before do
      allow(SolidusGraphqlApi::Queries::Product::OptionTypesQuery).to receive(:new).and_return(query_object)
    end

    after { subject.option_types }

    it { expect(SolidusGraphqlApi::Queries::Product::OptionTypesQuery).to receive(:new).with(product: product) }

    it { expect(query_object).to receive(:call) }
  end

  describe '#product_properties' do
    before do
      allow(SolidusGraphqlApi::Queries::Product::ProductPropertiesQuery).
        to receive(:new).with(product: product).
        and_return(query_object)
    end

    after { subject.product_properties }

    it { expect(query_object).to receive(:call) }
  end

  describe '#variants' do
    before do
      allow(SolidusGraphqlApi::Queries::Product::VariantsQuery).to receive(:new).and_return(query_object)
    end

    after { subject.variants }

    it { expect(SolidusGraphqlApi::Queries::Product::VariantsQuery).to receive(:new).with(product: product) }

    it { expect(query_object).to receive(:call) }
  end
end
