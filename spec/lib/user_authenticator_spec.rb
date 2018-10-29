require 'rails_helper'

describe UserAuthenticator do
  describe '.perform' do
    let(:user) { create :user, login: 'ngoc', password: 'secret' }

    shared_examples_for 'authenticator' do
      it 'creates and sets user access token' do
        expect(authenticator.authenticator).to receive(:perform).and_return(true)
        expect(authenticator.authenticator).to receive(:user).
          at_least(:once).and_return(user)
        expect{ authenticator.perform }.to change{ AccessToken.count }.by(1)
        expect(authenticator.access_token).to be_present
      end
    end

    context 'when initialized with code' do
      let(:authenticator) { described_class.new(code: 'sample') }
      let(:authenticator_class) { UserAuthenticator::Oauth }

      describe '#initialize' do
        it 'initialize proper authenticator' do
          expect(authenticator_class).to receive(:new).with('sample')
          authenticator
        end
      end

      it_behaves_like 'authenticator'
    end

    context 'when initialized with login and password' do
      let(:authenticator) { described_class.new(login: 'ngoc', password: 'secret') }
      let(:authenticator_class) { UserAuthenticator::Standard }

      describe '#initialize' do
        it 'initialize proper authenticator' do
          expect(authenticator_class).to receive(:new).with('ngoc', 'secret')
          authenticator
        end
      end

      it_behaves_like 'authenticator'
    end
  end
end
