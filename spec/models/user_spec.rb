require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    it 'have valid factory' do
      user = build :user
      expect(user).to be_valid
    end

    it 'validates the presence of login' do
      user = build :user, login: nil
      expect(user).not_to be_valid
      expect(user.errors.messages[:login]).to include("can't be blank")
    end

    it 'validates presence of password for standard provider' do
      user = build :user, login: 'ngoc', provider: 'standard', password: nil
      expect(user).not_to be_valid
      expect(user.errors.messages[:password]).to include("can't be blank")
    end

    it 'validates the presence of provider' do
      user = build :user, provider: ''
      expect(user).not_to be_valid
      expect(user.errors.messages[:provider]).to include("can't be blank")
    end

    it 'validates the unique of login' do
      user = create :user
      other_user = build :user, login: user.login
      expect(other_user).not_to be_valid
      expect(other_user.errors.messages[:login]).to include("has already been taken")

      other_user.login = 'my new login'
      expect(other_user).to be_valid
    end
  end
end
