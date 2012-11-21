class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :null => false
      t.integer :weibo_id, :null => false
      t.integer :ori_weibo_id, :null => false
      t.text :content, :limit => 300, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
