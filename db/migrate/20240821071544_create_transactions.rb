class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions, if_not_exists: true do |t|
      t.bigint  :wallet_source_id
      t.bigint  :wallet_destination_id
      t.string  :note
      t.integer :status
      t.integer :transaction_type # withdraw, deposit, transfer

      t.timestamps
    end

    # composite index
    add_index(
      :transactions,
      [:wallet_source_id, :wallet_destination_id],
      name: 'index_transactions_on_wallet_source_and_destination'
    )
  end

  def down
    drop_table :transactions, if_exists: true
  end
end
