# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_query :completed_orders do
  connection_field :completed_orders, query: :completed_orders, freeze_date: true do
    let(:current_user) { create :user, email: 'email1@example.com' }
    let(:query_context) { { current_user: current_user } }

    context 'when there are not any completed orders' do
      it { expect(subject.dig(:data, :completedOrders, :nodes)).to eq [] }
    end

    context 'when there are some completed orders' do
      let(:order1) do
        create(
          :completed_order_with_pending_payment,
          id: 1,
          user: current_user,
          guest_token: 'fake guest token 1',
          number: 'fake order number 1'
        )
      end
      let(:order2) do
        create(
          :completed_order_with_pending_payment,
          id: 2,
          user: current_user,
          guest_token: 'fake guest token 2',
          number: 'fake order number 2'
        )
      end
      let!(:completed_orders) { [order1, order2] }

      it { is_expected.to match_response('completed_orders') }
    end

    describe 'billing and shipping address fields' do
      let(:ship_address_1_country) { create :country, id: 1 }
      let(:ship_address_1_state) { create :state, id: 1, country: ship_address_1_country }
      let(:bill_address_1_country) { create :country, id: 2 }
      let(:bill_address_1_state) { create :state, id: 2, country: bill_address_1_country }
      let(:ship_address_2_country) { create :country, id: 3 }
      let(:ship_address_2_state) { create :state, id: 3, country: ship_address_2_country }
      let(:bill_address_2_country) { create :country, id: 4 }
      let(:bill_address_2_state) { create :state, id: 4, country: bill_address_2_country }
      let(:ship_address1) do
        create(
          :address,
          id: 1,
          zipcode: '10001',
          address1: 'A Different Road',
          country: ship_address_1_country,
          state: ship_address_1_state
        )
      end
      let(:bill_address1) do
        create(
          :address,
          id: 2,
          zipcode: '10002',
          address1: 'PO Box 1337',
          country: bill_address_1_country,
          state: bill_address_1_state
        )
      end
      let(:ship_address2) do
        create(
          :address,
          id: 3,
          zipcode: '10003',
          address1: 'A Different Road',
          country: ship_address_2_country,
          state: ship_address_2_state
        )
      end
      let(:bill_address2) do
        create(
          :address,
          id: 4,
          zipcode: '10004',
          address1: 'PO Box 1337',
          country: bill_address_2_country,
          state: bill_address_2_state
        )
      end
      let(:order1) do
        create(
          :completed_order_with_pending_payment,
          id: 1,
          user: current_user,
          ship_address: ship_address1,
          bill_address: bill_address1
        )
      end
      let(:order2) do
        create(
          :completed_order_with_pending_payment,
          id: 2,
          user: current_user,
          ship_address: ship_address2,
          bill_address: bill_address2
        )
      end
      let!(:completed_orders) { [order1, order2] }

      connection_field :shipping_address, query: 'completed_orders/shipping_address' do
        it { is_expected.to match_response('completed_orders/shipping_address') }
      end

      connection_field :billing_address, query: 'completed_orders/billing_address' do
        it { is_expected.to match_response('completed_orders/billing_address') }
      end
    end

    connection_field :line_items, query: 'completed_orders/line_items' do
      let!(:order) do
        create :completed_order_with_pending_payment, id: 1, user: current_user, line_items_count: 2
      end

      it { is_expected.to match_response('completed_orders/line_items').with_args(line_items: order.line_items) }
    end

    connection_field :available_payment_methods, query: 'completed_orders/available_payment_methods' do
      let!(:order) do
        create :completed_order_with_pending_payment, id: 1, user: current_user
      end

      it {
        expect(subject).
          to match_response('completed_orders/available_payment_methods').
          with_args(available_payment_methods: order.available_payment_methods)
      }
    end

    connection_field :payments, query: 'completed_orders/payments' do
      let!(:order) { create :completed_order_with_pending_payment, id: 1, user: current_user }

      it { is_expected.to match_response('completed_orders/payments').with_args(payments: order.payments) }
    end

    connection_field :adjustments, query: 'completed_orders/adjustments' do
      let(:promotion) { create :promotion_with_order_adjustment, code: 'solidus' }
      let(:promotion_code) { promotion.codes.first }

      let(:tax_rate) { create :tax_rate }
      let!(:tax_adjustment) { create :adjustment, source: tax_rate, order: order }

      let!(:order) { create :completed_order_with_pending_payment, id: 1, user: current_user }

      before do
        promotion.actions.first.perform(
          order: order,
          promotion: promotion,
          promotion_code: promotion_code
        )
      end

      it { is_expected.to match_response('completed_orders/adjustments').with_args(adjustments: order.adjustments) }
    end
  end
end
