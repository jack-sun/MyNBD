class CreateFollowings < ActiveRecord::Migration
  def self.up
    create_table :followings, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :null => false
      t.integer :following_user_id, :null => false

      t.timestamps
    end

    add_index :followings, :user_id
  end

  def self.down
    drop_table :followings
  end
end
