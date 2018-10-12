require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe '.create' do
    context 'when invalid request' do
      let(:errors) do
        {
          "status"=>"401",
          "source"=>{ "pointer"=>"/code" },
          "title"=> "Authentication code is invalid",
          "detail"=>"You mush provide valid code in order to exchange it for token"
        }
      end
      it 'returns 401 status code' do
        post :create
        expect(response).to have_http_status(401)
      end
      it 'returns proper error body' do
        post :create
        expect(json['errors']).to include(errors)
      end
    end
    context 'when success request' do
    end
  end
end
