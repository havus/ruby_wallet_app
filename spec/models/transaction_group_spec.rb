# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionGroup, type: :model do
  describe 'associations' do
    it { should belong_to(:source_wallet).class_name('Wallet').optional }
    it { should belong_to(:target_wallet).class_name('Wallet').optional }
    it { should have_many(:entries).class_name('TransactionEntry').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:transaction_type) }

    context 'when validating wallets for deposit' do
      let_it_be(:target_wallet) { create(:wallet) }

      it 'is valid with nil source_wallet and present target_wallet' do
        transaction_group = build(:transaction_group, transaction_type: :deposit, source_wallet: nil, target_wallet: target_wallet)
        expect(transaction_group).to be_valid
      end

      it 'is invalid with a present source_wallet' do
        source_wallet = create(:wallet)
        transaction_group = build(:transaction_group, transaction_type: :deposit, source_wallet: source_wallet, target_wallet: target_wallet)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('source_wallet must be nil for deposit transaction')
      end

      it 'is invalid with nil target_wallet' do
        transaction_group = build(:transaction_group, transaction_type: :deposit, source_wallet: nil, target_wallet: nil)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('target_wallet must be present for deposit transaction')
      end
    end

    context 'when validating wallets for withdraw' do
      let_it_be(:source_wallet) { create(:wallet) }

      it 'is valid with present source_wallet and nil target_wallet' do
        transaction_group = build(:transaction_group, transaction_type: :withdraw, source_wallet: source_wallet, target_wallet: nil)
        expect(transaction_group).to be_valid
      end

      it 'is invalid with a present target_wallet' do
        target_wallet = create(:wallet)
        transaction_group = build(:transaction_group, transaction_type: :withdraw, source_wallet: source_wallet, target_wallet: target_wallet)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('target_wallet must be nil for withdraw transaction')
      end

      it 'is invalid with nil source_wallet' do
        transaction_group = build(:transaction_group, transaction_type: :withdraw, source_wallet: nil, target_wallet: nil)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('source_wallet must be present for deposit transaction')
      end
    end

    context 'when validating wallets for transfer' do
      let_it_be(:source_wallet) { create(:wallet) }
      let_it_be(:target_wallet) { create(:wallet) }

      it 'is valid with both source_wallet and target_wallet present' do
        transaction_group = build(:transaction_group, transaction_type: :transfer, source_wallet: source_wallet, target_wallet: target_wallet)
        expect(transaction_group).to be_valid
      end

      it 'is invalid with either source_wallet or target_wallet missing' do
        transaction_group = build(:transaction_group, transaction_type: :transfer, source_wallet: nil, target_wallet: target_wallet)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('source_wallet and target_wallet must be present for transfer transaction')

        transaction_group = build(:transaction_group, transaction_type: :transfer, source_wallet: source_wallet, target_wallet: nil)
        expect(transaction_group).not_to be_valid
        expect(transaction_group.errors[:transaction_type]).to include('source_wallet and target_wallet must be present for transfer transaction')
      end
    end
  end
end
