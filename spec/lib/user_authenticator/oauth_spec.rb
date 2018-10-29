require 'rails_helper'

describe UserAuthenticator::Oauth do
  describe '.perform' do
    let(:authenticator) { described_class.new('sample_code') }
    subject { authenticator.perform }

    context 'when code is incorrect' do
      let(:error) {
        double('Sawyer::Resource', error: 'bad_verification_code')
      }
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return(error)
      end

      it 'raises error' do
        expect{ subject }.to raise_error(
          UserAuthenticator::Oauth::AuthenticationError
        )
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
      let(:user_data) do {
        login: 'ngoc',
        url: 'http://ngoc.com',
        avatar_url: 'http://ngoc.com/avatar',
        name: 'Ngoc'
      } end
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return('valid-access-token')
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user_data)
      end

      it 'save the user if user does not exist' do
        expect{ subject }.to change{ User.count }.by(1)
      end

      it 'reuse the existed user' do
        @user = create :user, user_data
        expect{ subject }.not_to change{ User.count }
      end

      it "creates and set user's access token" do
        expect{ subject }.to change{ AccessToken.count }.by(1)
        expect(authenticator.access_token).to be_present
      end
    end
  end
end
