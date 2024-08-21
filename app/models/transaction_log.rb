# frozen_string_literal: true

class TransactionLog < ApplicationRecord
  belongs_to :transaction

  enum log_type: { debit: 0, credit: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :log_type, presence: true
end
