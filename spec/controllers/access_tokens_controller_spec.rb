require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe 'POST .create' do
    shared_examples_for "unauthorized_request" do
      let(:authorization_error) do
        {
          "status"=>"401",
          "source"=>{ "pointer"=>"/code" },
          "title"=> "Authentication code is invalid",
          "detail"=>"You mush provide valid code in order to exchange it for token"
        }
      end

      it 'returns 401 status code' do
        subject
        expect(response).to have_http_status(401)
      end

      it 'returns proper error body' do
        subject
        expect(json['errors']).to include(authorization_error)
      end
    end


    context 'when no code provided' do
      subject { post :create }
      it_behaves_like "unauthorized_request"
    end

    context 'when code is invalid' do
      subject { post :create , params: { code: 'invalid_code' } }
      it_behaves_like "unauthorized_request"
    end

    context 'when success request' do
      let(:user_data) do {
        login: 'ngoc',
        url: 'http://ngoc.com',
        avatar_url: 'http://ngoc.com/avatar',
        name: 'Ngoc'
      } end

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return('validaccesstoken')
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user_data)
      end
      subject { post :create, params: { code: 'valid_code' } }
      it 'returns 201 code' do
        subject
        expect(response).to have_http_status(:created)
      end


      it 'returns proper json body' do
        expect{ subject }.to change{ User.count }.by(1)
        user = User.find_by_login('ngoc')
        expect(json_data['attributes']).to eq(
          { 'token' => user.access_token.token }
        )
      end
    end
  end

  describe 'DELETE .destroy' do
    shared_examples_for 'forbidden_requests' do
      let(:forbidden_error) do
        {
          'status' => '403',
          'source' => { 'pointer' => 'header/authorization' },
          'title' => 'Not authorized',
          'detail' => 'You have no right to access this resource'
        }
      end

      it 'returns 403 status code' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'should return proper json error' do
        subject
        expect(json['errors']).to eq([forbidden_error])
      end
    end

    context 'when invalid request' do
      subject { delete :destroy }
      it_behaves_like 'forbidden_requests'
    end

    context 'when valid request' do
    end
  end
end
