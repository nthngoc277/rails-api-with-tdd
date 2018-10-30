require 'rails_helper'

describe RegistrationsController do
  describe '#create' do
    subject { post :create, params: params }
    context 'when invalid data provided' do
      let(:params) do
        {
          data: {
            attributes: {
              login: nil,
              password: nil
            }
          }
        }
      end

      it 'returns unprocessable_entity status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'not create a user' do
        expect{ subject }.not_to change{ User.count }
      end

      it 'returns error messages in response body' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/login' },
            'detail' => "can't be blank"
          },
          {
            'source' => { 'pointer' => '/data/attributes/password' },
            'detail' => "can't be blank"
          }
        )
      end
    end

    context 'when valid data provided' do
      let(:params) do
        {
          data: {
            attributes: {
              login: 'ngoc',
              password: 'secret'
            }
          }
        }
      end

      it 'returns 201 http status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'creates user' do
        expect(User.exists?(login: 'ngoc')).to be_falsey
        expect{ subject }.to change{ User.count }.by(1)
        expect(User.exists?(login: 'ngoc')).to be_truthy
      end

      it 'returns proper json' do
        subject
        expect(json_data['attributes']).to eq({
          'login' => 'ngoc',
          'avatar-url' => nil,
          'url' => nil,
          'name' => nil
        })
      end
    end
  end
end
