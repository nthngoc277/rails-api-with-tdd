require 'rails_helper'

describe ArticlesController do
  describe 'GET index' do
    subject { get :index }
    it 'returns success code' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns proper json' do
      articles = create_list :article, 2
      subject
      articles.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq ({
          'title' => article.title,
          'content' => article.content,
          'slug' => article.slug
        })
      end
    end
  end
end
