require 'rails_helper'

RSpec.describe WalletServices::GetBalance do
  describe '#perform' do
    subject { described_class.new }

    context 'when the wallet exists' do
      let_it_be(:wallet_1) { create(:wallet) }
      let_it_be(:wallet_2) { create(:wallet) }

      let_it_be(:withdraw_transaction) do
        create(
          :transaction_group,
          status: :failed,
          transaction_type: :withdraw,
          source_wallet: wallet_1,
        )
      end
      let_it_be(:withdraw_transaction_entries) do
        [
          create(
            :transaction_entry,
            transaction_group: withdraw_transaction,
            wallet: withdraw_transaction.source_wallet,
            entry_type: :credit,
            amount: 50,
          ),
        ]
      end

      let_it_be(:deposit_transaction) do
        create(
          :transaction_group,
          status: :completed,
          transaction_type: :deposit,
          target_wallet: wallet_1,
        )
      end
      let_it_be(:deposit_transaction_entries) do
        [
          create(
            :transaction_entry,
            wallet: deposit_transaction.target_wallet,
            transaction_group: deposit_transaction,
            entry_type: :credit,
            amount: 100,
          ),
        ]
      end

      let_it_be(:transfer_transaction) do
        create(
          :transaction_group,
          status: :completed,
          transaction_type: :transfer,
          source_wallet: wallet_1,
          target_wallet: wallet_2,
        )
      end
      let_it_be(:transfer_transaction_entries) do
        [
          create(
            :transaction_entry,
            wallet: transfer_transaction.source_wallet,
            transaction_group: transfer_transaction,
            entry_type: :debit,
            amount: 30,
          ),
          create(
            :transaction_entry,
            wallet: transfer_transaction.target_wallet,
            transaction_group: transfer_transaction,
            entry_type: :credit,
            amount: 30,
          ),
        ]
      end

      it 'calculates the correct balance' do
        subject.perform(wallet_1.id)
        expect(subject.result.to_f).to eq((100 - 30).to_f)
        expect(subject.errors).to be_empty

        subject.perform(wallet_2.id)
        expect(subject.result.to_f).to eq(30.to_f)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the wallet does not exist' do
      it 'returns an error' do
        subject.perform(0)

        expect(subject.result).to eq(0)
        expect(subject.errors).to include('Wallet not found')
      end
    end
  end

  describe '#get_wallet' do
    subject { described_class.new }

    context 'when the wallet is found' do
      let_it_be(:wallet) { create(:wallet) }

      it 'returns the wallet' do
        expect(subject.send(:get_wallet, wallet.id)).to eq(wallet)
      end
    end

    context 'when the wallet is not found' do
      it 'adds an error and returns nil' do
        expect(subject.send(:get_wallet, 0)).to be_nil
        expect(subject.errors).to include('Wallet not found')
      end
    end
  end

  describe '#credit_amount' do
    let_it_be(:wallet) { create(:wallet) }
    let_it_be(:transaction_group) do
      create(
        :transaction_group,
        target_wallet: wallet,
        status: :completed,
        transaction_type: :transfer,
      )
    end
    let_it_be(:transaction_entry) do
      create(
        :transaction_entry,
        wallet: wallet,
        transaction_group: transaction_group,
        entry_type: :credit,
        amount: 30,
      )
    end

    subject { described_class.new }

    it 'calculates the total credit amount' do
      expect(subject.send(:credit_amount, wallet.id)).to eq(transaction_entry.amount)
    end
  end

  describe '#debit_amount' do
    let_it_be(:wallet) { create(:wallet) }
    let_it_be(:transaction_group) do
      create(
        :transaction_group,
        source_wallet: wallet,
        status: :completed,
        transaction_type: :transfer,
      )
    end
    let_it_be(:transaction_entry) do
      create(
        :transaction_entry,
        wallet: wallet,
        transaction_group: transaction_group,
        entry_type: :debit,
        amount: 30,
      )
    end

    subject { described_class.new }

    it 'calculates the total debit amount' do
      expect(subject.send(:debit_amount, wallet.id)).to eq(transaction_entry.amount)
    end
  end
end
