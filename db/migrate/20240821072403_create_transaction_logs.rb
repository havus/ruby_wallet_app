class CreateTransactionLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :transaction_logs, if_not_exists: true do |t|
      t.bigint :wallet_id
      t.bigint :transaction_id
      t.integer :log_type # debit, credit
      t.decimal :amount, precision: 38, scale: 6

      t.timestamps
    end

    add_index :transaction_logs, :wallet_id
    add_index :transaction_logs, [:wallet_id, :log_type]
    add_index :transaction_logs, :transaction_id
  end

  def down
    drop_table :transaction_logs, if_exists: true
  end
end
