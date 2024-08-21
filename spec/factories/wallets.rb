# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    association :owner, factory: :user # Change to :team or :stock as needed
    address { "wallet_address_#{SecureRandom.hex}" }
  end
end
