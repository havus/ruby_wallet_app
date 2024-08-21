# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Walletable module' do
    include_context :walletable

    it 'includes the Walletable module' do
      expect(User.included_modules).to include(Walletable)
    end
  end

  describe 'attributes' do
    it { is_expected.to respond_to(:password_hash) }
    it { is_expected.to respond_to(:email) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password_hash) }
  end

  describe 'wallet association' do
    let_it_be(:user) { create(:user) }
    let_it_be(:wallet) { create(:wallet, owner: user) }

    it 'destroys the associated wallet when the user is destroyed' do
      expect { user.destroy }.to change { Wallet.count }.by(-1)
    end
  end

  describe 'password encryption' do
    let_it_be(:user) { create(:user, password: 'password123') }

    it 'encrypts the password' do
      expect(user.password_hash).not_to eq('password123')
    end

    it 'correctly decrypts the password' do
      expect(user.password).to eq('password123')
    end

    it 'changes the password hash when the password is changed' do
      original_password_hash = user.password_hash
      user.password = 'newpassword456'
      user.save!

      expect(user.password_hash).not_to eq(original_password_hash)
      expect(user.password).to eq('newpassword456')
    end
  end
end
