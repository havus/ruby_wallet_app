class CreateTransactionGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :transaction_groups, if_not_exists: true do |t|
      t.bigint  :source_wallet_id
      t.bigint  :target_wallet_id

      t.string  :note
      t.integer :status
      t.integer :transaction_type # withdraw, deposit, transfer

      t.timestamps
    end
  end

  def down
    drop_table :transaction_groups, if_exists: true
  end
end
