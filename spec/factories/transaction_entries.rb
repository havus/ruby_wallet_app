# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_entry do
    association :transaction_group, factory: :transaction_group
    entry_type { :credit }
    amount { 100 }
  end
end
