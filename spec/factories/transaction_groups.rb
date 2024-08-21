# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_group do
    status { :pending }
    transaction_type { :deposit }
  end
end
