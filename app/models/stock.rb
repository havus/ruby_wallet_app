# frozen_string_literal: true

# == Schema Information
#
# t.string "name"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class Stock < ApplicationRecord
  include Walletable
end
