# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusGraphqlApi::Types::Json do
  describe '.coerce_input' do
    subject { described_class.coerce_input(value, nil) }

    let(:value) do
      {
        number: 1,
        string: 'string',
        id: 'U3ByZWU6OkNvdW50cnktMQ==', # Spree::Country-1
        generic_base64: 'U3ByZWU6OkNvdW50cnktdGVzdA==', # Spree::Country-test
        hash: {
          id: 'U3ByZWU6OlByb21vdGlvbkFjdGlvbi04', # Spree::PromotionAction-8
          generic_base64: 'U3ByZWU6OkNvdW50cnktdGVzdA==', # Spree::Country-test
          strings_array: [
            'string1', 'string2'
          ],
          ids_array: [
            'U3ByZWU6OkNvdW50cnktMg==', 'U3ByZWU6OkNvdW50cnktMw==' # Spree::Country-2, Spree::Country-3
          ]
        },
        strings_array: [
          'string1', 'string2'
        ],
        numbers_array: [
          1, 2
        ],
        ids_array: [
          'U3ByZWU6OkNvdW50cnktMg==', 'U3ByZWU6OkNvdW50cnktMw==' # Spree::Country-2, Spree::Country-3
        ],
        generic_base64_array: [
          'VGVzdDE=', 'VGVzdDI=' # Test1, Test2
        ],
        hash_array: [
          {
            ids_array: [
              'U3ByZWU6OlByb21vdGlvbkFjdGlvbi02',
              'U3ByZWU6OlByb21vdGlvbkFjdGlvbi04' # Spree::PromotionAction-6, Spree::PromotionAction-8
            ],
            ids_hash: {
              id: 'U3ByZWU6OkFkanVzdG1lbnQtNQ==', # Spree::Adjustment-5
              id_action_parameters: ActionController::Parameters.new(id: 'U3ByZWU6Ok9yZGVyLTI=') # Spree::Order-2
            }
          },
          {
            string: 'string',
            strings_array: [
              'string3', 'string4'
            ],
            numbers_array: [
              3, 4
            ],
            id: 'U3ByZWU6Ok9yZGVyLTE=' # Spree::Order-1
          }
        ]
      }
    end

    let(:result) do
      {
        number: 1,
        string: 'string',
        id: 1,
        generic_base64: 'U3ByZWU6OkNvdW50cnktdGVzdA==',
        hash: {
          id: 8,
          generic_base64: 'U3ByZWU6OkNvdW50cnktdGVzdA==',
          strings_array: [
            'string1', 'string2'
          ],
          ids_array: [
            2, 3
          ]
        },
        strings_array: [
          'string1', 'string2'
        ],
        numbers_array: [
          1, 2
        ],
        ids_array: [
          2, 3
        ],
        generic_base64_array: [
          'VGVzdDE=', 'VGVzdDI='
        ],
        hash_array: [
          {
            ids_array: [
              6, 8
            ],
            ids_hash: {
              id: 5,
              id_action_parameters: ActionController::Parameters.new(id: 2)
            }
          },
          {
            string: 'string',
            strings_array: [
              'string3', 'string4'
            ],
            numbers_array: [
              3, 4
            ],
            id: 1
          }
        ]
      }
    end

    it { is_expected.to eq(result) }
  end
end
