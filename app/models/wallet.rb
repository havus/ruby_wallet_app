# frozen_string_literal: true

# == Schema Information
#
# t.bigint "owner_id"
# t.string "owner_type"
# t.string "address"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class Wallet < ApplicationRecord
  belongs_to :owner, polymorphic: true

  has_many :transactions_as_source, class_name: 'TransactionGroup', foreign_key: :source_wallet_id
  has_many :transactions_as_target, class_name: 'TransactionGroup', foreign_key: :target_wallet_id

  has_many :entries, class_name: 'TransactionEntry', foreign_key: :wallet_id

  has_many :debit_logs, -> { debit }, class_name: 'TransactionLog', foreign_key: :wallet_id
  has_many :credit_logs, -> { credit }, class_name: 'TransactionLog', foreign_key: :wallet_id

  validates :address, presence: true, uniqueness: true
end
