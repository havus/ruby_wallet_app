# frozen_string_literal: true

class Team < ApplicationRecord
  include Walletable

  validates :email, presence: true, uniqueness: true
  validates :hash_password, presence: true
end
