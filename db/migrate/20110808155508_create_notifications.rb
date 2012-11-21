class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :recipient_id, :null => false
      t.integer :target_id, :null => false
      t.string :target_type, :null => false
      t.integer :unread, :limit => 4, :default => 1
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
