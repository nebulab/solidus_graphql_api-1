# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_mutation :mark_default_ship_address, mutation: :mark_default_ship_address do
  let(:mutation_context) { Hash[current_ability: Spree::Ability.new(current_user), current_user: current_user] }
  let(:mutation_variables) { Hash[input: { addressId: SolidusGraphqlApi::Schema.id_from_object(address, nil, nil) }] }

  let(:current_user) { create(:user_with_addresses) }
  let(:address) { create(:address) }

  context "when current user isn't present" do
    let(:current_user) { nil }

    it { expect(subject[:data][:markDefaultShipAddress]).to be_nil }
    it { expect(subject[:errors].first[:message]).to eq I18n.t(:"unauthorized.default") }
  end

  context "when current user is present" do
    context "and the given address id is wrong" do
      it { expect(subject[:data][:markDefaultShipAddress]).to be_nil }
      it { expect(subject[:errors].first[:message]).to eq I18n.t(:'activerecord.exceptions.not_found') }
    end

    context "and the given address id is correct" do
      before { current_user.addresses << address }

      let(:ship_address) { subject[:data][:markDefaultShipAddress][:user][:shipAddress] }

      it { expect(ship_address[:id]).to eq address.id }
    end
  end
end
