# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_mutation :apply_coupon_code, mutation: :apply_coupon_code do
  let(:current_ability) { Spree::Ability.new(nil) }
  let(:guest_token) { nil }
  let(:mutation_context) {
    Hash[
      current_ability: current_ability,
      current_order: current_order,
      order_token: guest_token
    ]
  }

  let(:coupon_code) { 'coupon_code' }
  let(:mutation_variables) {
    Hash[
      input: {
        couponCode: coupon_code
      }
    ]
  }

  shared_examples "responds with an unauthorized error" do
    it { expect(subject[:data][:selectShippingRate]).to be_nil }
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
    let(:user_errors) { subject[:data][:applyCouponCode][:errors] }

    context 'and the current ability is unauthorized' do
      include_examples "responds with an unauthorized error"
    end

    context 'and the current ability is authorized' do
      let(:guest_token) { current_order.guest_token }
      let(:response_order) { subject[:data][:applyCouponCode][:order] }

      context "and the given coupon code is applicable" do
        let(:flat_rate_discount) { 10.0 }

        before {
          create(:promotion, :with_line_item_adjustment, adjustment_rate: flat_rate_discount, code: coupon_code)
        }

        it { expect(response_order[:adjustmentTotal]).to eq((-flat_rate_discount).to_s) }
        it { expect(response_order[:number]).to eq(current_order.number) }
        it { expect(response_order[:email]).to eq(current_order.email) }
        it { expect(user_errors).to be_empty }
        it { is_expected.to_not have_key(:errors) }
      end

      context "and the given coupon code doesn't exist" do
        it { expect(response_order[:adjustmentTotal].to_d).to be_zero }
        it { expect(response_order[:number]).to eq(current_order.number) }
        it { expect(response_order[:email]).to eq(current_order.email) }
        it { expect(user_errors.first[:path]).to eq(["input", "order", "couponCode"]) }
        it { expect(user_errors.first[:message]).to eq("The coupon code you entered doesn't exist. Please try again.") }
        it { is_expected.to_not have_key(:errors) }
      end
    end
  end
end
