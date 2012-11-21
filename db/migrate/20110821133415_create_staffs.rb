class CreateStaffs < ActiveRecord::Migration
  def self.up
    create_table :staffs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name, :limit => 64,:null =>false, :unique => true
      t.string :real_name, :limit => 64,:null =>false
      t.string :hashed_password, :limit => 32,:null =>false
      t.string :salt, :limit => 32
      t.string :email, :limit => 64
      t.string :phone, :limit => 32
      t.integer :user_type, :limit => 4, :default => 0
      t.string :comment, :limit => 500
      t.integer :status, :limit => 4, :default => 1, :null => false
      t.integer :creator_id, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :staffs
  end
end
