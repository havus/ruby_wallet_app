# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    name { 'Team Alpha' }
    email { 'teamalpha@example.com' }
    password_hash { 'password_hash' }
  end
end
