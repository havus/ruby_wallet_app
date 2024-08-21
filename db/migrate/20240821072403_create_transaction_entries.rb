class CreateTransactionEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :transaction_entries, if_not_exists: true do |t|
      t.bigint  :transaction_group_id
      t.bigint  :wallet_id

      t.integer :entry_type # debit, credit
      t.decimal :amount, precision: 38, scale: 6

      t.timestamps
    end

    add_index :transaction_entries, [:wallet_id, :entry_type]
    add_index :transaction_entries, :transaction_group_id
  end

  def down
    drop_table :transaction_entries, if_exists: true
  end
end
