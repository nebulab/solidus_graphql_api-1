# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_query :currentOrder, query: :current_order, freeze_date: true do
  let!(:order) { create :order_with_line_items, id: 1, number: 'fake number' }

  let(:query_context) { { current_order: order } }
  let(:shipment_number) { order.shipments.first.number }
  let(:variant_sku) { order.line_items.first.variant.sku }

  field :currentOrder do
    it {
      expect(subject).to match_response(:current_order).with_args(shipment_number: shipment_number,
                                                                  variant_sku: variant_sku)
    }
  end
end
