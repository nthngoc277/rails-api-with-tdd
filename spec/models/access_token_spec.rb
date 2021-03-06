require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'has valid factory' do
    end

    it 'validates token' do
    end
  end

  describe '#new' do
    it 'has token present after initialization' do
      expect(AccessToken.new.token).to be_present
    end

    it 'generats unique token' do
      user = create :user
      expect{ user.create_access_token }.to change{ AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'generates token once' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
