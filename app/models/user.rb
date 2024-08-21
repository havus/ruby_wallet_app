# frozen_string_literal: true

class User < ApplicationRecord
  include Walletable

  validates :email, presence: true, uniqueness: true
  validates :hash_password, presence: true
end
