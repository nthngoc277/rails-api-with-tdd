require 'rails_helper'

describe UserAuthenticator::Standard do
  describe '#perform' do
    let(:authenticator) { described_class.new('ngoc', 'secret') }
    subject { authenticator.perform }

    shared_examples_for 'invalid authentication' do
      before { user }
      it 'raises an error' do
        expect{ subject }.to raise_error(
          UserAuthenticator::Standard::AuthenticationError
        )
        expect(authenticator.user).to be_nil
      end
    end

    context 'when invalid login' do
      let(:user) { create :user, login: 'abc', password: 'password' }
      it_behaves_like 'invalid authentication'
     end

    context 'when invalid password' do
      let(:user) { create :user, login: 'ngoc', password: 'password' }
      it_behaves_like 'invalid authentication'
    end

    context 'when success auth' do
      let(:user) { create :user, login: 'ngoc', password: 'secret' }
      before { user }
      it 'set the user found in db' do
        expect{ subject }.not_to change{ User.count }
        expect(authenticator.user).to eq(user)
      end
    end
  end
end
