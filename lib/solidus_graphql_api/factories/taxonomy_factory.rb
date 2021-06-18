# frozen_string_literal: true

FactoryBot.modify do
  factory :taxonomy do
    transient do
      root_taxon_id {}
    end

    after :create do |taxonomy, options|
      if options.root_taxon_id.present? && taxonomy.root.id != options.root_taxon_id
        taxonomy.root.update(id: options.root_taxon_id)
      end
    end

    trait :with_taxon_meta do
      after :create do |taxonomy|
        taxonomy.root.update(
          description: 'Brand description',
          meta_description: 'Brand meta description',
          meta_keywords: 'Brand meta keywords',
          meta_title: 'Brand meta title',
        )
      end
    end

    trait :with_root_icon do
      after :create do |taxonomy|
        taxonomy.root.update(icon: Spree::Core::Engine.root.join('lib', 'spree', 'testing_support', 'fixtures', 'blank.jpg').open)
      end
    end
  end
end
