# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    email { 'john@example.com' }
    hash_password { 'password_hash' }
  end
end
