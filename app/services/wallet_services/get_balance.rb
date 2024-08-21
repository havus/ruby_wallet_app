# frozen_string_literal: true

module WalletServices
  class GetBalance
    def initialize
      @errors = []
      @result = 0
    end

    attr_reader :errors, :result

    # @params [Integer] wallet_id
    # @return Decimal
    def perform(wallet_id)
      wallet = get_wallet(wallet_id)
      return if wallet.blank?

      @result = credit_amount(wallet_id) - debit_amount(wallet_id)

      @errors.blank?
    end

    private

    # @params [Integer] wallet_id
    # @return Wallet
    def get_wallet(wallet_id)
      Wallet.find(wallet_id)
    rescue ActiveRecord::RecordNotFound
      @errors << 'Wallet not found'
      nil
    end

    # @params [Integer] wallet_id
    # @return Decimal
    def credit_amount(wallet_id)
      get_transaction_log(wallet_id, :credit).sum(:amount)
    end

    # @params [Integer] wallet_id
    # @return Decimal
    def debit_amount(wallet_id)
      get_transaction_log(wallet_id, :debit).sum(:amount)
    end

    # @params [Integer] wallet_id
    # @params [Symbol] entry_type, value between :credit or :debit
    # @return ActiveRecordRelation
    def get_transaction_log(wallet_id, entry_type)
      finder_query = 'transaction_entries.wallet_id = :wallet_id' \
        ' AND transaction_entries.entry_type = :entry_type' \
        ' AND transaction_groups.status = :status'

      ::TransactionEntry.select('transaction_entries.amount').joins(
        ' INNER JOIN transaction_groups' \
        '   ON transaction_entries.transaction_group_id = transaction_groups.id'
      )
      .where(
        finder_query,
        wallet_id: wallet_id,
        entry_type: ::TransactionEntry.entry_types[entry_type],
        status: ::TransactionGroup.statuses[:completed],
      )
    end
  end
end
