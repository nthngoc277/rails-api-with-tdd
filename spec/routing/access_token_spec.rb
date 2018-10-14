require 'rails_helper'

describe 'access token routes' do
  it 'routes to access_tokens create action' do
    expect(post '/login').to route_to('access_tokens#create')
  end

  it 'routes to access_token destroy action' do
    expect(delete '/logout').to route_to('access_tokens#destroy')
  end
end
