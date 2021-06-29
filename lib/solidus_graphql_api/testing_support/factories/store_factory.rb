# frozen_string_literal: true

FactoryBot.modify do
  factory :store do
    trait :with_defaults do
      cart_tax_country_iso { 'US' }
      code { 'solidus' }
      default_currency { 'USD' }
      meta_description { 'store description' }
      meta_keywords { 'store, metaKeywords' }
      name { 'Solidus Test Store' }
      seo_title { 'Store Title' }
      url { 'www.example.com' }
    end
  end
end
