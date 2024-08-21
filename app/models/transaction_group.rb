# frozen_string_literal: true

# == Schema Information
#
# t.bigint "source_wallet_id"
# t.bigint "target_wallet_id"
# t.string "note"
# t.integer "status"
# t.integer "transaction_type"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class TransactionGroup < ApplicationRecord
  belongs_to :source_wallet, class_name: 'Wallet', foreign_key: :source_wallet_id, optional: true
  belongs_to :target_wallet, class_name: 'Wallet', foreign_key: :target_wallet_id, optional: true

  has_many :entries, class_name: 'TransactionEntry', foreign_key: :transaction_group_id, dependent: :destroy

  enum :status, { pending: 0, completed: 1, failed: 2 }
  enum :transaction_type, { deposit: 0, withdraw: 1, transfer: 2 }

  validates :status, presence: true
  validates :transaction_type, presence: true

  validate :wallets_present

  private

  def wallets_present
    if deposit?
      if source_wallet.present?
        errors.add(:transaction_type, 'source_wallet must be nil for deposit transaction')
      end

      if target_wallet.nil?
        errors.add(:transaction_type, 'target_wallet must be present for deposit transaction')
      end
    end

    if withdraw?
      if source_wallet.nil?
        errors.add(:transaction_type, 'source_wallet must be present for deposit transaction')
      end

      if target_wallet.present?
        errors.add(:transaction_type, 'target_wallet must be nil for withdraw transaction')
      end
    end

    if transfer? && (source_wallet.nil? || target_wallet.nil?)
      errors.add(:transaction_type, 'source_wallet and target_wallet must be present for transfer transaction')
    end
  end
end
