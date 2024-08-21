# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :owner, polymorphic: true

  has_many :transactions_as_source, class_name: 'Transaction', foreign_key: 'wallet_source_id'
  has_many :transactions_as_destination, class_name: 'Transaction', foreign_key: 'wallet_destination_id'

  validates :address, presence: true, uniqueness: true
end
