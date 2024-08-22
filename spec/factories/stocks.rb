# frozen_string_literal: true

FactoryBot.define do
  factory :stock do
    name { "Stock #{Faker::Name.name}" }
  end
end
