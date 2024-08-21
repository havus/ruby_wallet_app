# frozen_string_literal: true

# == Schema Information
#
# t.bigint "transaction_group_id"
# t.bigint "wallet_id"
# t.integer "entry_type"
# t.decimal "amount", precision: 38, scale: 6
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class TransactionEntry < ApplicationRecord
  belongs_to :transaction_group, class_name: 'TransactionGroup', foreign_key: :transaction_group_id
  belongs_to :wallet, class_name: 'Wallet', foreign_key: :wallet_id

  enum :entry_type, { debit: 0, credit: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :entry_type, presence: true
end
