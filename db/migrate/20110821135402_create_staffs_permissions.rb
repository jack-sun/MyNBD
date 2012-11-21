class CreateStaffsPermissions < ActiveRecord::Migration
  def self.up
    create_table :staffs_permissions, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :column_id, :null =>false
      t.integer :staff_id, :null => false
      t.integer :creator_id, :null => false

      t.timestamps
    end
    add_index :staffs_permissions, :column_id
    add_index :staffs_permissions, :staff_id
  end

  def self.down
    drop_table :staffs_permissions
  end
end
