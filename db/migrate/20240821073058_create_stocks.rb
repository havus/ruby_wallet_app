class CreateStocks < ActiveRecord::Migration[7.2]
  def up
    create_table :stocks, if_not_exists: true do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :stocks, if_exists: true
  end
end
