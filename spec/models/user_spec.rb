# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  include_context :walletable

  describe 'attributes' do
    it { is_expected.to respond_to(:hash_password) }
    it { is_expected.to respond_to(:email) }
  end

  describe 'wallet association' do
    let_it_be(:user) { create(:user) }
    let_it_be(:wallet) { create(:wallet, owner: user) }

    it 'destroys the associated wallet when the user is destroyed' do
      expect { user.destroy }.to change { Wallet.count }.by(-1)
    end
  end
end
