# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'associations' do
    it { should belong_to(:owner) }
    it { should have_many(:transactions_as_source).class_name('TransactionGroup').with_foreign_key(:source_wallet_id) }
    it { should have_many(:transactions_as_target).class_name('TransactionGroup').with_foreign_key(:target_wallet_id) }
    it { should have_many(:entries).class_name('TransactionEntry').with_foreign_key(:wallet_id) }
  end

  describe 'validations' do
    it { should validate_presence_of(:address) }
    it { should validate_uniqueness_of(:address).case_insensitive }
  end

  describe 'polymorphic association' do
    it 'can belong to a User' do
      user = create(:user)
      wallet = create(:wallet, owner: user)

      expect(wallet.owner).to eq(user)
    end

    it 'can belong to a Team' do
      team = create(:team)
      wallet = create(:wallet, owner: team)

      expect(wallet.owner).to eq(team)
    end

    it 'can belong to a Stock' do
      stock = create(:stock)
      wallet = create(:wallet, owner: stock)

      expect(wallet.owner).to eq(stock)
    end
  end
end
