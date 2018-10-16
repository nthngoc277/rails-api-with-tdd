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

  describe 'GET show' do
    let(:article) { create :article }
    subject { get :show, params: { id: article.id } }

    it 'can be accessed succesffully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays right data for an article' do
      subject
      expect(json_data['id']).to eq article.id.to_s
      expect(json_data['attributes']).to eq ({
        'title' => article.title,
        'content' => article.content,
        'slug' => article.slug
      })
    end
  end

  describe 'POST create' do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before {
        request.headers['authorization'] = "Bearer #{access_token.token}"
      }
      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '', 
                content: ''
              }
            }
          }
        end
        subject { post :create, params: invalid_attributes }
        it 'returns 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank",
            },
            {
              'source' => { 'pointer' => '/data/attributes/content' },
              'detail' => "can't be blank",
            },
            {
              'source' => { 'pointer' => '/data/attributes/slug' },
              'detail' => "can't be blank",
            }
          )
        end
      end
    end

    context 'when success request sent' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before {
        request.headers['authorization'] = "Bearer #{access_token.token}"
      }
      let(:valid_attributes) do
        {
          'data' => {
            'attributes' => {
              'title' => 'this is some title', 
              'content' => 'this is some super content',
              'slug' => 'this-is-some-title'
            }
          }
        }
      end

      subject { post :create, params: valid_attributes }
      it 'has 201 status code' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'has proper json body' do
        subject
        expect(json_data['attributes']).to include(valid_attributes['data']['attributes'])
      end

      it 'creates the article' do
        expect{ subject }.to change{ Article.count }.by(1)
      end
    end
  end

  describe 'PUT update' do
    let(:article) { create :article }
    context 'when no code provided' do
      subject { patch :update, params: { id: article.id } }
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before {
        request.headers['authorization'] = 'Invalid code'
      }
      subject { patch :update, params: { id: article.id } }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before {
        request.headers['authorization'] = "Bearer #{access_token.token}"
      }
      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => '', 
                'content' => '',
                'slug' => ''
              }
            }
          }
        end
        subject { patch :update, params: { id: article.id }.merge(invalid_attributes) }
        it 'returns 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank",
            },
            {
              'source' => { 'pointer' => '/data/attributes/content' },
              'detail' => "can't be blank",
            },
            {
              'source' => { 'pointer' => '/data/attributes/slug' },
              'detail' => "can't be blank",
            }
          )
        end
      end

      context 'when valid parameters provided' do
        let(:user) { create :user }
        let(:access_token) { user.create_access_token }
        let(:article) { create :article }
        subject { patch :update, params: valid_attributes.merge(id: article.id) }
        before {
          request.headers['authorization'] = "Bearer #{access_token.token}"
          subject
        }
        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'this is some title', 
                'content' => 'this is some super content',
                'slug' => 'this-is-some-title'
              }
            }
          }
        end
        it 'has 200 status code' do
          expect(response).to have_http_status(:ok)
        end

        it 'has proper json body' do
          expect(json_data['attributes']).to include(valid_attributes['data']['attributes'])
        end

        it 'updates attributes' do
          article.reload
          expect(article.title).to eq(valid_attributes['data']['attributes']['title'])
          expect(article.content).to eq(valid_attributes['data']['attributes']['content'])
          expect(article.slug).to eq(valid_attributes['data']['attributes']['slug'])
        end
      end
    end
  end
end  
