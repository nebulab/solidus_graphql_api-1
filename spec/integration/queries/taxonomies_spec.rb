# frozen_string_literal: true

require 'spec_helper'

RSpec.describe_query :taxonomies do
  connection_field :taxonomies, query: :taxonomies, freeze_date: true do
    context 'when taxonomies does not exists' do
      it { expect(subject.dig(:data, :taxonomies, :nodes)).to eq [] }
    end

    context 'when taxonomies exists' do
      let!(:brand_taxonomy) { create(:taxonomy, :with_taxon_meta, :with_root_icon, id: 1, root_taxon_id: 1) }
      let!(:category_taxonomy) { create(:taxonomy, :with_root_icon, id: 2, name: 'Category', root_taxon_id: 2) }
      let!(:taxon) { create(:taxon, :with_icon, id: 3, name: 'Solidus', taxonomy: brand_taxonomy) }

      before do
        taxon.update(parent: brand_taxonomy.root)
      end

      it {
        expect(subject).to match_response(:taxonomies).with_args(brand_url: brand_taxonomy.taxons.first.icon.url,
                                                                 category_url: category_taxonomy.taxons.first.icon.url,
                                                                 taxon_url: taxon.icon.url)
      }
    end
  end
end
