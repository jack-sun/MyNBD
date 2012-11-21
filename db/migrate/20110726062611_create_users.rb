class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string    :email, :limit => 64, :null => false, :unique => true
      t.string    :nickname, :limit => 64, :null => false, :unique => true
      t.string    :hashed_password, :limit => 64, :null => false
      t.string    :salt, :limit => 64, :null => false
      t.integer   :reg_from, :default => 0
      t.integer   :user_type, :default => 1
      t.string    :auth_token, :limit => 32, :null => false, :unique => true
      t.integer   :status, :default => 0, :null => false
      t.string    :password_reset_token, :limit => 32, :unique => true
      t.datetime  :password_reset_sent_at
      t.string    :activate_token, :limit => 32, :unique => true
      t.datetime  :activate_sent_at
      t.integer   :followings_count,:default => 0
      t.integer   :followers_count,:default => 0
      t.integer   :stocks_count, :default => 0
      t.integer   :weibos_count,:default => 0

      t.timestamps
    end
    
    add_index :users, :email, :unique => true
    add_index :users, :nickname, :unique => true
    add_index :users, :auth_token, :unique => true
    add_index :users, :password_reset_token, :unique => true
    add_index :users, :activate_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
