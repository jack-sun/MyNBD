class CreateColumnsUsers < ActiveRecord::Migration
  def self.up
    create_table :columns_users do |t|
      t.integer :column_id, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :columns_users
  end
end
