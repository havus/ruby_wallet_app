# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WalletServices::Transfer do
  describe '#perform' do
    let_it_be(:source_wallet, reload: true) { create(:wallet) }
    let_it_be(:target_wallet, reload: true) { create(:wallet) }

    let(:payload) do
      {
        source_wallet_id: source_wallet.id,
        target_wallet_id: target_wallet.id,
        amount: 50.00,
        note: 'Transfer for testing',
      }
    end
    let(:errors) { double(:errors, full_messages: []) }

    subject { described_class.new }

    context 'when both wallets exist and the source wallet has sufficient funds' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(source_wallet).and_return(100.00)
      end

      it 'creates a transaction group and two transaction entries' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(1)
        .and change { TransactionEntry.count }.by(2)

        expect(subject.errors).to be_empty
      end

      it 'sets the transaction group to completed and transfer' do
        subject.perform(payload)
        transaction_group = TransactionGroup.last

        expect(transaction_group.status).to eq('completed')
        expect(transaction_group.transaction_type).to eq('transfer')
      end

      it 'creates a debit transaction entry for the source wallet' do
        subject.perform(payload)
        transaction_entry = TransactionEntry.where(wallet: source_wallet).debit.last

        expect(transaction_entry.amount).to eq(payload[:amount])
        expect(transaction_entry.entry_type).to eq('debit')
      end

      it 'creates a credit transaction entry for the target wallet' do
        subject.perform(payload)
        transaction_entry = TransactionEntry.where(wallet: target_wallet).credit.last

        expect(transaction_entry.amount).to eq(payload[:amount])
        expect(transaction_entry.entry_type).to eq('credit')
      end
    end

    context 'when the source wallet does not exist' do
      before do
        payload[:source_wallet_id] = 0
      end

      it 'adds an error and does not create any records' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(0)
        .and change { TransactionEntry.count }.by(0)

        expect(subject.errors).to include('Wallet with ID 0 not found')
      end
    end

    context 'when the target wallet does not exist' do
      before do
        payload[:target_wallet_id] = 0
      end

      it 'adds an error and does not create any records' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(0)
        .and change { TransactionEntry.count }.by(0)

        expect(subject.errors).to include('Wallet with ID 0 not found')
      end
    end

    context 'when the source wallet has insufficient funds' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(source_wallet).and_return(30.00)
      end

      it 'adds an error and does not create any records' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(0)
        .and change { TransactionEntry.count }.by(0)

        expect(subject.errors).to include('Insufficient funds in source wallet')
      end
    end

    context 'when there is an error saving the transaction group' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(source_wallet).and_return(100.00)
        allow_any_instance_of(TransactionGroup).to receive(:save).and_return(false)
        allow_any_instance_of(TransactionGroup).to receive(:errors).and_return(errors)
        allow(errors).to receive(:full_messages).and_return(['Dummy Error 1'])
      end

      it 'adds an error and rolls back the transaction' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(0)
        .and change { TransactionEntry.count }.by(0)

        expect(subject.errors).to match_array(['transaction_group_error: Dummy Error 1'])
      end

      it 'sets transaction_group to nil' do
        subject.perform(payload)
        expect(subject.transaction_group).to be_nil
      end
    end

    context 'when there is an error saving a transaction entry' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(source_wallet).and_return(100.00)
        allow_any_instance_of(TransactionEntry).to receive(:save).and_return(false)
        allow_any_instance_of(TransactionEntry).to receive(:errors).and_return(errors)
        allow(errors).to receive(:full_messages).and_return(['Dummy Error 2'])
      end

      it 'adds an error and rolls back the transaction' do
        expect {
          subject.perform(payload)
        }.to change { TransactionGroup.count }.by(0)
        .and change { TransactionEntry.count }.by(0)

        expect(subject.errors).to match_array(['transaction_entry_error: Dummy Error 2'])
      end

      it 'sets transaction_group.id to nil' do
        subject.perform(payload)
        expect(subject.transaction_group.id).to be_nil
      end
    end
  end

  describe '#get_wallet' do
    subject { described_class.new }

    context 'when the wallet exists' do
      let_it_be(:wallet) { create(:wallet) }

      it 'returns the wallet' do
        expect(subject.send(:get_wallet, wallet.id)).to eq(wallet)
      end
    end

    context 'when the wallet does not exist' do
      it 'adds an error and returns nil' do
        expect(subject.send(:get_wallet, 0)).to be_nil
        expect(subject.errors).to include('Wallet with ID 0 not found')
      end
    end
  end
end
