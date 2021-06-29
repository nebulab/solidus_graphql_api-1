# frozen_string_literal: true

module SolidusGraphqlApi
  module Mutations
    module User
      class MarkDefaultShipAddress < BaseMutation
        null true

        argument :address_id, ID, required: true, loads: Types::Address

        field :user, Types::User, null: true

        def resolve(address:)
          current_user.mark_default_ship_address(address)

          { user: current_user.reload }
        end

        def ready?(*)
          return true if current_user.present?

          raise CanCan::AccessDenied
        end

        def authorized?(address:)
          current_user.user_addresses.find_by!(address_id: address.id)
        end
      end
    end
  end
end
