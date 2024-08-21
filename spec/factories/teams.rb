# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    name { 'Team Alpha' }
    email { 'teamalpha@example.com' }
    hash_password { 'password_hash' }
  end
end
