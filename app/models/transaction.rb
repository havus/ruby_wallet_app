# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :wallet_source, class_name: 'Wallet', optional: true
  belongs_to :wallet_destination, class_name: 'Wallet', optional: true
  has_many :transaction_logs, dependent: :destroy

  enum status: { pending: 0, completed: 1, failed: 2 }
  enum transaction_type: { debit: 0, credit: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :transaction_type, presence: true

  validate :wallets_present

  private

  def wallets_present
    if wallet_source.nil? && wallet_destination.nil?
      errors.add(:base, 'Either wallet_source or wallet_destination must be present')
    end
  end
end
