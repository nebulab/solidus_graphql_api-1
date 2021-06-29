# frozen_string_literal: true

module SolidusGraphqlApi
  module Types
    module InputObjects
      class AddressInput < Base::InputObject
        description "Address."

        argument :address1, String, required: true
        argument :address2, String, required: false
        argument :alternative_phone, String, required: false
        argument :city, String, required: true
        argument :company, String, required: false
        argument :country_id, ID, required: true, loads: Types::Country
        argument :name, String, required: true
        argument :phone, String, required: true
        argument :state_name, String, required: false
        argument :state_id, ID, required: false, loads: Types::State
        argument :zipcode, String, required: true
      end
    end
  end
end
