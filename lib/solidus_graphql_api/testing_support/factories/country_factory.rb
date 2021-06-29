# frozen_string_literal: true

FactoryBot.modify do
  factory :country do
    trait :with_states do
      after :create do |country|
        create(:state, id: 1, country: country)
        create(:state, id: 2, country: country, state_code: 'CA')
      end
    end
  end
end
