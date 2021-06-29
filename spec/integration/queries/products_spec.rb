# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_query :products, query: :products, freeze_date: true do
  connection_field :products do
    subject { query_response.dig(:data, :products, :nodes) }

    let(:current_user) { create :user }
    let(:current_pricing_options) { Spree::Config.pricing_options_class.new }
    let(:query_context) do
      { current_user: current_user,
        current_pricing_options: current_pricing_options }
    end

    context 'when products do not exist' do
      it { is_expected.to eq [] }
    end

    context 'when products exist' do
      let!(:solidus_t_shirt) { create(:product, name: 'Solidus T-Shirt', id: 1, price: 19.99) }
      let!(:ruby_mug) { create(:product, name: 'Ruby Mug', id: 2, price: 9.99) }
      let!(:solidus_mug) { create(:product, name: 'Solidus Mug ', id: 3, price: 9.99) }
      let!(:solidus_tote) { create(:product, name: 'Solidus Tote', id: 4, price: 15.99) }

      context 'when no query is passed' do
        it {
          expect(subject).to match_array([{ id: solidus_t_shirt.id }, { id: ruby_mug.id }, { id: solidus_mug.id },
                                          { id: solidus_tote.id }])
        }
      end

      context 'when a query is passed' do
        let(:taxon) { create(:taxon, products: [solidus_tote]) }
        let(:search) { { price_range_any: ["Under $10.00", "$15.00 - $18.00"] } }
        let(:taxon_id) { SolidusGraphqlApi::Schema.id_from_object(taxon, nil, nil) }
        let(:query_variables) { { query: { taxon: taxon_id, keywords: "Solidus", search: search } } }

        it { is_expected.to match_array([{ id: solidus_tote.id }]) }
      end
    end
  end
end
