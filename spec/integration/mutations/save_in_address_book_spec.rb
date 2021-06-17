# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_mutation :save_in_address_book, mutation: :save_in_address_book do
  let(:default) { false }
  let(:country_states_required) { false }
  let(:address) {
    create(:address, name: "Jane Von Doe", country: create(:country, states_required: country_states_required))
  }
  let(:address_attributes) {
    {
      name: address.name,
      address1: address.address1,
      city: address.city,
      countryId: SolidusGraphqlApi::Schema.id_from_object(address.country, nil, nil),
      phone: address.phone,
      zipcode: address.zipcode,
    }
  }
  let(:mutation_context) { Hash[current_ability: Spree::Ability.new(current_user), current_user: current_user] }
  let(:mutation_variables) {
    {
      input: {
        address: address_attributes,
        default: default
      }
    }
  }

  context "when current user isn't present" do
    let(:current_user) { nil }

    it { expect(subject[:data][:saveInAddressBook]).to be_nil }
    it { expect(subject[:errors].first[:message]).to eq I18n.t(:"unauthorized.default") }
  end

  context "when current user is present" do
    let(:current_user) { create(:user) }
    let(:default_address) { subject[:data][:saveInAddressBook][:user][:defaultAddress] }
    let(:user_addresses) { subject[:data][:saveInAddressBook][:user][:addresses][:nodes] }
    let(:user_errors) { subject[:data][:saveInAddressBook][:errors] }

    context "when user doesn't have addresses" do
      context "and given attributes are correct" do
        it { expect(default_address[:name]).to eq(address[:name]) }
        it { expect(user_addresses.count).to eq 1 }
        it { expect(user_addresses.first[:name]).to eq(address[:name]) }
        it { expect(user_errors).to be_empty }
      end

      context "and given attributes are incorrect" do
        let(:country_states_required) { true }

        it { expect(default_address).to be_nil }
        it { expect(user_addresses.count).to eq 0 }
        it { expect(user_errors.first[:path]).to eq ["input", "address", "state"] }
        it { expect(user_errors.first[:message]).to eq "can't be blank" }
      end
    end

    context "when user have addresses" do
      let(:current_user) { create(:user_with_addresses) }

      context "and given attributes are correct" do
        it { expect(default_address).to_not be_nil }
        it { expect(user_addresses.count).to eq 3 }
        it { expect(user_addresses.map{ |address| address[:name] }).to include(address[:name]) }
        it { expect(user_errors).to be_empty }

        context 'when default false' do
          it { expect(default_address[:name]).to_not eq(address[:name]) }
        end

        context 'when default true' do
          let(:default) { true }

          it { expect(default_address[:name]).to eq(address[:name]) }
        end
      end

      context "and given attributes are incorrect" do
        let(:country_states_required) { true }

        it { expect(default_address).to_not be_nil }
        it { expect(user_addresses.count).to eq 2 }
        it { expect(user_errors.first[:path]).to eq ["input", "address", "state"] }
        it { expect(user_errors.first[:message]).to eq "can't be blank" }
      end
    end
  end
end
