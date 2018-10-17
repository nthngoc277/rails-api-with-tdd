require 'rails_helper'

describe 'articles routes' do
  it 'routes to article index' do
    expect(get '/articles').to route_to('articles#index')
  end

  it 'routes to show article' do
    expect(get "articles/1").to route_to('articles#show', id: '1')
  end

  it 'routes to articles create' do
    expect(post '/articles').to route_to('articles#create')
  end

  it 'routes to articles destroy' do
    expect(delete 'articles/1').to route_to('articles#destroy', id: '1')
  end
end
