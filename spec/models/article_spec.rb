require 'rails_helper'

RSpec.describe Article, type: :model do
  describe '#validations' do
    it 'tests that factory is valid' do
      expect(build :article).to be_valid
    end

    it 'validates the presence of title' do
      article = build :article, title: ''
      expect(article).not_to be_valid
      expect(article.errors.messages[:title]).to include("can't be blank")
    end

    it 'validates the presence of content' do
      article = build :article, content: ''
      expect(article).not_to be_valid
      expect(article.errors.messages[:content]).to include("can't be blank")
    end

    it 'validates the presence of slug' do
      article = build :article, slug: ''
      expect(article).not_to be_valid
      expect(article.errors.messages[:slug]).to include("can't be blank")
    end

    it 'validates the uniqueness of slug' do
      article = create :article
      invalid_article = build :article, slug: article.slug
      expect(invalid_article).not_to be_valid
      expect(invalid_article.errors.messages[:slug]).to include("has already been taken")
    end
  end

  describe '.recent' do
    it 'recent article in the descending order by created at' do
      old_article = create :article
      new_article = create :article
      expect(described_class.recent).to eq [new_article, old_article]
      old_article.update_column :created_at, Time.now
      expect(described_class.recent).to eq [old_article, new_article]
    end
  end
end
