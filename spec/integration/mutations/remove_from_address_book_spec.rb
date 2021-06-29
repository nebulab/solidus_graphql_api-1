# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_mutation :remove_from_address_book, mutation: :remove_from_address_book do
  let(:mutation_context) { Hash[current_ability: Spree::Ability.new(current_user), current_user: current_user] }
  let(:mutation_variables) { Hash[input: { addressId: SolidusGraphqlApi::Schema.id_from_object(address, nil, nil) }] }

  let(:address) { create(:address) }
  let(:current_user) { create(:user_with_addresses) }

  context "when current user isn't present" do
    let(:current_user) { nil }

    it { expect(subject[:data][:removeFromAddressBook]).to be_nil }
    it { expect(subject[:errors].first[:message]).to eq I18n.t(:"unauthorized.default") }
  end

  context "when current user is present" do
    context "and the given address id is wrong" do
      it { expect(subject[:data][:removeFromAddressBook]).to be_nil }
      it { expect(subject[:errors].first[:message]).to eq I18n.t(:"unauthorized.default") }
    end

    context "and the given address id is correct" do
      before { current_user.addresses << address }

      let(:user_addresses) { subject[:data][:removeFromAddressBook][:user][:addresses][:nodes] }

      it { expect(user_addresses.count).to eq 2 }
      it { expect(user_addresses.map{ |address| address[:id] }).to_not include(address.id) }

      describe 'default address' do
        let(:ship_address) { subject[:data][:removeFromAddressBook][:user][:shipAddress] }

        context "when address is the default" do
          before { current_user.mark_default_ship_address(address.id) }

          it { expect(ship_address).to be_nil }
        end

        context "when address isn't the default" do
          it { expect(ship_address[:id]).to_not eq address.id }
        end
      end
    end
  end
end
