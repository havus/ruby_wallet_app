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
  validates :password, presence: true, if: :password_required?

  def password
    return if password_hash.blank?

    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    return if new_password.blank?

    @password = Password.create(new_password)
    self.password_hash = @password
  end

  private

  def password_required?
    password_hash.blank? || @password.present?
  end
end
