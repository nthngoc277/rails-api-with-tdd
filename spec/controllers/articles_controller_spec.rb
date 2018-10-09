require 'rails_helper'

describe ArticlesController do
  describe 'GET index' do
    subject { get :index }
    it 'returns success code' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns proper json' do
      create_list :article, 2
      subject
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq ({
          'title' => article.title,
          'content' => article.content,
          'slug' => article.slug
        })
      end
    end

    it 'returns list of article in the proper order' do
      old_article = create :article
      new_article = create :article
      subject
      expect(json_data.first['id']).to eq new_article.id.to_s
      expect(json_data.last['id']).to eq old_article.id.to_s
    end

    it 'paginates the result' do
      create_list :article, 3
      get :index, params: { page: 2, per_page: 1 }
      expected_article = Article.recent.second
      expect(json_data.first['id']).to eq expected_article.id.to_s
    end
  end
end
