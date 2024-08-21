class CreateTeams < ActiveRecord::Migration[7.2]
  def up
    create_table :teams, if_not_exists: true do |t|
      t.string :name
      t.string :email
      t.string :password_hash

      t.timestamps
    end
  end

  def down
    drop_table :teams, if_exists: true
  end
end
