class CreateWallets < ActiveRecord::Migration[7.2]
  def up
    create_table :wallets, if_not_exists: true do |t|
      t.bigint :owner_id
      t.string :owner_type
      t.string :address

      t.timestamps
    end

    add_index :wallets, [:owner_id, :owner_type]
  end

  def down
    drop_table :wallets, if_exists: true
  end
end
