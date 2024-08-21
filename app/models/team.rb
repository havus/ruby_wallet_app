# frozen_string_literal: true

# == Schema Information
#
# t.string "name"
# t.string "email"
# t.string "password_hash"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

require 'bcrypt'

class Team < ApplicationRecord
  include Walletable
  include BCrypt

  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
