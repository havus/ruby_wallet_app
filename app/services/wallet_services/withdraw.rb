# frozen_string_literal: true

module WalletServices
  class Withdraw
    def initialize
      @errors = []
      @transaction_group = nil
    end

    attr_reader :errors, :transaction_group

    # @params [Hash] :payload
    #   @option payload [Integer] :wallet_id
    #   @option payload [Decimal] :amount
    # @return Decimal
    def perform(payload)
      wallet_id = payload[:wallet_id]

      ActiveRecord::Base.transaction do
        wallet = get_wallet(wallet_id)
        raise ActiveRecord::Rollback if wallet.blank?

        balance = WalletServices::GetBalance.new.perform(wallet)
        if balance < payload[:amount].to_d
          @errors << 'Insufficient funds'
          raise ActiveRecord::Rollback
        end

        @transaction_group = create_transaction_group(wallet_id, payload[:note])

        create_transaction_entry(transaction_group.id, wallet_id, payload[:amount])
      end

      @errors.blank?
    end

    private

    # @params [Integer] wallet_id
    # @return Wallet
    def get_wallet(wallet_id)
      Wallet.lock.find(wallet_id)
    rescue ActiveRecord::RecordNotFound
      @errors << 'Wallet not found'
      nil
    end

    def create_transaction_group(wallet_id, note)
      transaction_group = TransactionGroup.new(
        source_wallet_id: wallet_id,
        target_wallet_id: nil,
        note: note,
        status: :completed,
        transaction_type: :withdraw,
      )
      unless transaction_group.save
        @errors << "transaction_group_error: #{transaction_group.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end

      transaction_group
    end

    def create_transaction_entry(transaction_group_id, wallet_id, amount)
      transaction_entry = TransactionEntry.new(
        transaction_group_id: transaction_group_id,
        wallet_id: wallet_id,
        entry_type: :debit,
        amount: amount.to_d,
      )

      unless transaction_entry.save
        @errors << "transaction_entry_error: #{transaction_entry.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
