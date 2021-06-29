# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusGraphqlApi::Context do
  let(:schema_context) { described_class.new(request: request) }

  let(:headers) do
    headers_hash = {}
    if defined?(authorization_token) && authorization_token
      headers_hash['Authorization'] =
        "Bearer #{authorization_token}"
    end
    headers_hash['X-Spree-Order-Token'] = order_token if defined?(order_token) && order_token
    headers_hash
  end

  let(:request) { ActionDispatch::TestRequest.create.tap { |request| request.headers.merge!(headers) } }

  describe '#to_h' do
    subject { schema_context.to_h }

    let(:current_user) { Spree::User.new }
    let(:current_ability) { Spree::Ability.new(nil) }
    let!(:default_store) { create(:store, default: true) }
    let(:current_order) { build(:order) }
    let(:current_pricing_options) { Spree::Config.pricing_options_class.new }
    let(:order_token) { "order_token" }

    before do
      allow(schema_context).to receive(:current_user).and_return(current_user)
      allow(schema_context).to receive(:current_ability).and_return(current_ability)
      allow(schema_context).to receive(:current_order).and_return(current_order)
      allow(schema_context).to receive(:current_pricing_options).and_return(current_pricing_options)
    end

    it { is_expected.to be_an(Hash) }

    it { is_expected.to have_key(:current_user) }
    it { expect(subject[:current_user]).to eq current_user }

    it { is_expected.to have_key(:current_ability) }
    it { expect(subject[:current_ability]).to eq current_ability }

    it { is_expected.to have_key(:current_store) }
    it { expect(subject[:current_store]).to eq default_store }

    it { is_expected.to have_key(:current_order) }
    it { expect(subject[:current_order]).to eq current_order }

    it { is_expected.to have_key(:current_pricing_options) }
    it { expect(subject[:current_pricing_options]).to eq current_pricing_options }

    it { is_expected.to have_key(:order_token) }
    it { expect(subject[:order_token]).to eq order_token }
  end

  describe '#current_user' do
    subject { schema_context.current_user }

    context 'when headers do not contains the authorization token' do
      it { is_expected.to be_nil }
    end

    context 'when headers contains the authorization token' do
      let!(:user) { create(:user).tap(&:generate_spree_api_key!) }

      context 'and the authorization token is invalid' do
        let(:authorization_token) { 'wrongauthorizationtoken' }

        it { is_expected.to be_nil }
      end

      context 'and the authorization token is valid' do
        let(:authorization_token) { user.spree_api_key }

        it { is_expected.to eq user }
      end
    end
  end

  describe '#current_ability' do
    subject { schema_context.current_ability }

    after { subject }

    context 'when headers do not contains the authorization token' do
      it { is_expected.to be_a Spree::Ability }
      it { expect(Spree::Ability).to receive(:new).with(nil) }
    end

    context 'when headers contains the authorization token' do
      let!(:user) { create(:user).tap(&:generate_spree_api_key!) }

      context 'and the authorization token is invalid' do
        let(:authorization_token) { 'wrongauthorizationtoken' }

        it { is_expected.to be_a Spree::Ability }
        it { expect(Spree::Ability).to receive(:new).with(nil) }
      end

      context 'and the authorization token is valid' do
        let(:authorization_token) { user.spree_api_key }

        it { is_expected.to be_a Spree::Ability }
        it { expect(Spree::Ability).to receive(:new).with(user) }
      end
    end
  end

  describe '#current_store' do
    subject { schema_context.current_store }

    let!(:default_store) { create(:store, default: true) }

    it { is_expected.to eq default_store }
  end

  describe '#current_pricing_options' do
    subject { schema_context.current_pricing_options }

    let(:default_currency) { 'EUR' }
    let(:country_iso) { 'IT-it' }
    let!(:default_store) do
      create(:store, default: true, default_currency: default_currency, cart_tax_country_iso: country_iso)
    end

    it { is_expected.to be_a Spree::Config.pricing_options_class }

    it do
      expect(Spree::Config.pricing_options_class).to receive(:new).with(
        currency: default_currency,
        country_iso: country_iso
      )
      subject
    end
  end

  describe '#order_token' do
    subject { schema_context.order_token }

    let(:order_token) { "order_token" }

    it { is_expected.to eq order_token }
  end

  describe '#current_order' do
    subject { schema_context.current_order }

    let(:current_store) { create :store, default: true }

    before do
      allow(schema_context).to receive(:current_user).and_return(current_user)
    end

    context 'when there is a current user' do
      let(:current_user) { create :user }

      before do
        allow(schema_context).to receive(:current_user).and_return(current_user)
      end

      context 'when the current user has one incompleted order in the current store' do
        let!(:order) { create :order, user: current_user, store: current_store }

        it { is_expected.to eq order }

        context 'when is provided an order token for an incompleted order in the current store' do
          let(:other_order) { create :order, store: current_store }
          let(:order_token) { other_order.guest_token }

          it { is_expected.to eq order }
        end
      end

      context 'when the current user has many incompleted orders in the current store' do
        let!(:first_created_order) {
          create :order, user: current_user, store: current_store, created_at: Time.zone.yesterday
        }
        let!(:last_created_order) {
          create :order, user: current_user, store: current_store, created_at: Time.zone.today
        }

        it { is_expected.to eq last_created_order }
      end

      context 'when the current user has one completed order in the current store' do
        let!(:order) { create :completed_order_with_totals, user: current_user, store: current_store }

        it { is_expected.to be_nil }
      end

      context 'when the current user has one incompleted order in another store' do
        let(:other_store) { create :store, default: false }
        let(:order) { create :order, user: current_user, store: other_store }

        before do
          current_store
          order
        end

        it { is_expected.to be_nil }
      end

      context 'when the current user does not have any orders' do
        it { is_expected.to be_nil }
      end
    end

    context 'when there is no current user' do
      let(:current_user) {}
      let(:order_token) {}

      context 'when is provided an order token for an incompleted order in the current store' do
        let(:order) { create :order, store: current_store }
        let(:order_token) { order.guest_token }

        it { is_expected.to eq order }
      end

      context 'when is provided an order token for a completed order in the current store' do
        let(:order) { create :completed_order_with_totals, store: current_store }
        let(:order_token) { order.guest_token }

        it { is_expected.to be_nil }
      end

      context 'when is provided an order token for an incompleted order in another store' do
        let(:other_store) { create :store, default: false }
        let(:order) { create :order, user: current_user, store: other_store }
        let(:order_token) { order.guest_token }

        before { current_store }

        it { is_expected.to be_nil }
      end

      context 'when is provided no order token' do
        it { is_expected.to be_nil }
      end
    end
  end
end
