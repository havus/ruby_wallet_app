# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WalletServices::Deposit do
  describe '#perform' do
    let_it_be(:wallet) { create(:wallet) }

    let(:payload) do
      {
        wallet_id: wallet.id,
        amount: 100.00,
        note: 'Deposit for testing',
      }
    end
    let(:errors) { double(:errors, full_messages: []) }

    subject { described_class.new }

    context 'when the wallet exists' do
      it 'creates a transaction group and transaction entry' do
        expect { subject.perform(payload) }.to change { TransactionGroup.count }.by(1)
                                                .and change { TransactionEntry.count }.by(1)

        expect(subject.errors).to be_empty
      end

      it 'sets the transaction group to completed and deposit' do
        subject.perform(payload)
        transaction_group = TransactionGroup.last

        expect(transaction_group.status).to eq('completed')
        expect(transaction_group.transaction_type).to eq('deposit')
      end

      it 'creates a transaction entry with the correct amount' do
        subject.perform(payload)
        transaction_entry = TransactionEntry.last

        expect(transaction_entry.amount).to eq(payload[:amount])
        expect(transaction_entry.entry_type).to eq('credit')
      end
    end

    context 'when the wallet does not exist' do
      before do
        payload[:wallet_id] = 0
      end

      it 'adds an error and does not create any records' do
        expect { subject.perform(payload) }.not_to change { TransactionGroup.count }
        expect(subject.errors).to include('Wallet not found')
      end
    end

    context 'when there is an error saving the transaction group' do
      before do
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

      it 'set transaction_group to nil' do
        subject.perform(payload)
        expect(subject.transaction_group).to be_nil
      end
    end

    context 'when there is an error saving the transaction entry' do
      before do
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

      it 'set transaction_group.id to nil' do
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
        expect(subject.errors).to include('Wallet not found')
      end
    end
  end
end
