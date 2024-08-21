# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

wallet_owners = []

(0..3).each do
  user = User.new(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: Faker::Lorem.characters(number: 10)
  )
  user.save
  wallet_owners << user
end
(0..3).each do
  team = Team.new(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: Faker::Lorem.characters(number: 10)
  )
  team.save
  wallet_owners << team
end
(0..3).each do
  wallet_owners << Stock.create!(name: Faker::Company.name)
end

wallet_owners.each_with_index do |owner, index|
  wallet = Wallet.create!(address: Faker::Crypto.md5, owner: owner)

  # failed due to insufficient balance
  failed_withdraw_transaction = TransactionGroup.create!(
    transaction_type: :withdraw,
    note: Faker::Lorem.sentence(word_count: 3),
    status: :failed,
    source_wallet: wallet,
    target_wallet: nil,
  )
  TransactionEntry.create!(
    wallet: wallet,
    transaction_group: failed_withdraw_transaction,
    entry_type: :debit,
    amount: 100,
  )

  completed_deposit_transaction = TransactionGroup.create!(
    source_wallet: nil,
    target_wallet: wallet,
    transaction_type: :deposit,
    note: Faker::Lorem.sentence(word_count: 3),
    status: :completed,
  )
  TransactionEntry.create!(
    wallet: wallet,
    transaction_group: completed_deposit_transaction,
    entry_type: :credit,
    amount: 100,
  )

  next if index == 0

  target_wallet = wallet_owners[index - 1].wallet
  transfer_amount = 30

  transfer_transaction_group = TransactionGroup.create!(
    source_wallet: wallet,
    target_wallet: target_wallet,
    transaction_type: :transfer,
    note: Faker::Lorem.sentence(word_count: 3),
    status: :completed,
  )

  TransactionEntry.create!(
    wallet: wallet,
    transaction_group: transfer_transaction_group,
    entry_type: :debit,
    amount: transfer_amount,
  )
  TransactionEntry.create!(
    wallet: target_wallet,
    transaction_group: transfer_transaction_group,
    entry_type: :credit,
    amount: transfer_amount,
  )
end
