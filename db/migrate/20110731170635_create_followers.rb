class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :null => false
      t.integer :follower_user_id, :null => false

      t.timestamps
    end

    add_index :followers, :user_id
  end

  def self.down
    drop_table :followers
  end
end
