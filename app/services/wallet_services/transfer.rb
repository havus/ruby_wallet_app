# frozen_string_literal: true

module WalletServices
  class Transfer
    def initialize
      @errors = []
      @transaction_group = nil
    end

    attr_reader :errors, :transaction_group

    # @params [Hash] :payload
    #   @option payload [Integer] :source_wallet_id
    #   @option payload [Integer] :target_wallet_id
    #   @option payload [Decimal] :amount
    # @return Boolean
    def perform(payload)
      source_wallet_id = payload[:source_wallet_id]
      target_wallet_id = payload[:target_wallet_id]

      ActiveRecord::Base.transaction do
        source_wallet = get_wallet(source_wallet_id)
        target_wallet = get_wallet(target_wallet_id)

        if source_wallet.blank? || target_wallet.blank?
          raise ActiveRecord::Rollback
        end

        balance = WalletServices::GetBalance.new.perform(source_wallet)
        if balance < payload[:amount].to_d
          @errors << 'Insufficient funds in source wallet'
          raise ActiveRecord::Rollback
        end

        @transaction_group = create_transaction_group(source_wallet_id, target_wallet_id, payload[:note])

        create_transaction_entry(transaction_group.id, source_wallet_id, payload[:amount], :debit)
        create_transaction_entry(transaction_group.id, target_wallet_id, payload[:amount], :credit)
      end

      @errors.blank?
    end

    private

    # @params [Integer] wallet_id
    # @return Wallet
    def get_wallet(wallet_id)
      Wallet.lock.find(wallet_id)
    rescue ActiveRecord::RecordNotFound
      @errors << "Wallet with ID #{wallet_id} not found"
      nil
    end

    def create_transaction_group(source_wallet_id, target_wallet_id, note)
      transaction_group = TransactionGroup.new(
        source_wallet_id: source_wallet_id,
        target_wallet_id: target_wallet_id,
        note: note,
        status: :completed,
        transaction_type: :transfer,
      )
      unless transaction_group.save
        @errors << "transaction_group_error: #{transaction_group.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end

      transaction_group
    end

    def create_transaction_entry(transaction_group_id, wallet_id, amount, entry_type)
      transaction_entry = TransactionEntry.new(
        transaction_group_id: transaction_group_id,
        wallet_id: wallet_id,
        entry_type: entry_type,
        amount: amount.to_d,
      )

      unless transaction_entry.save
        @errors << "transaction_entry_error: #{transaction_entry.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
