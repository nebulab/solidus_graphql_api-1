# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_mutation :add_addresses_to_checkout, mutation: :add_addresses_to_checkout do
  let(:current_ability) { Spree::Ability.new(nil) }
  let(:guest_token) { nil }
  let(:mutation_context) {
    Hash[
      current_ability: current_ability,
      current_order: current_order,
      order_token: guest_token
    ]
  }

  let(:country_id) { SolidusGraphqlApi::Schema.id_from_object(create(:country), nil, nil) }
  let(:address) {
    address = build_stubbed(:address).slice(:address1, :city, :phone, :zipcode)
    address[:countryId] = country_id
    address.transform_keys! { |key| key.camelize(:lower) }
  }
  let(:billing_address_name) { 'John Von Doe' }
  let(:shipping_address_name) { 'Jane Von Doe' }
  let(:mutation_variables) {
    Hash[
      input: {
        billingAddress: address.merge(name: billing_address_name),
        shippingAddress: address.merge(name: shipping_address_name)
      }
    ].tap do |variables|
      variables[:input][:shipToBillingAddress] = ship_to_billing_address if defined?(ship_to_billing_address)
    end
  }

  shared_examples "responds with an unauthorized error" do
    it { expect(subject[:data][:addAddressesToCheckout]).to be_nil }
    it { expect(subject[:errors].first[:message]).to eq I18n.t(:"unauthorized.default") }
  end

  context "when current order isn't present" do
    let(:current_order) { nil }

    include_examples "responds with an unauthorized error"
  end

  context "when current order is completed" do
    let(:current_order) { create(:completed_order_with_totals) }

    include_examples "responds with an unauthorized error"
  end

  context "when current order isn't completed" do
    let(:current_order) { create(:order_with_line_items) }
    let(:user_errors) { subject[:data][:addAddressesToCheckout][:errors] }

    context 'and the current ability is unauthorized' do
      include_examples "responds with an unauthorized error"
    end

    context 'and the current ability is authorized' do
      let(:guest_token) { current_order.guest_token }
      let(:response_order) { subject[:data][:addAddressesToCheckout][:order] }

      context 'with wrong arguments' do
        let(:billing_address_name) { '' }

        it { expect(response_order[:number]).to eq(current_order.number) }
        it { expect(user_errors.first[:path]).to eq(["input", "order", "billAddress", "name"]) }
        it { expect(user_errors.first[:message]).to eq("can't be blank") }
        it { is_expected.to_not have_key(:errors) }
      end

      context 'with correct arguments' do
        context 'when shipToBillingAddress argument' do
          describe 'is true' do
            let(:ship_to_billing_address) { true }

            it { expect(response_order[:number]).to eq(current_order.number) }
            it { expect(response_order[:state]).to eq('address') }
            it { expect(response_order[:billingAddress][:name]).to eq(billing_address_name) }
            it { expect(response_order[:shippingAddress][:name]).to eq(billing_address_name) }
            it { expect(user_errors).to be_empty }
            it { is_expected.to_not have_key(:errors) }
          end

          describe 'is false' do
            let(:ship_to_billing_address) { false }

            it { expect(response_order[:number]).to eq(current_order.number) }
            it { expect(response_order[:state]).to eq('address') }
            it { expect(response_order[:billingAddress][:name]).to eq(billing_address_name) }
            it { expect(response_order[:shippingAddress][:name]).to eq(shipping_address_name) }
            it { expect(user_errors).to be_empty }
            it { is_expected.to_not have_key(:errors) }
          end

          describe 'is not present' do
            it { expect(response_order[:number]).to eq(current_order.number) }
            it { expect(response_order[:state]).to eq('address') }
            it { expect(response_order[:billingAddress][:name]).to eq(billing_address_name) }
            it { expect(response_order[:shippingAddress][:name]).to eq(shipping_address_name) }
            it { expect(user_errors).to be_empty }
            it { is_expected.to_not have_key(:errors) }
          end
        end
      end
    end
  end
end
