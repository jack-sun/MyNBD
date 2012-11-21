class CreateWeibos < ActiveRecord::Migration
  def self.up
    create_table :weibos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :owner, :polymorphic => true
      t.integer :owner_id, :null =>false
      t.string :owner_type, :null => false
      t.integer :has_tag, :limit => 4, :default => 0
      t.text :content, :limt => 300, :null => false
      t.integer :parent_weibo_id, :default => 0, :null => false
      t.integer :ori_weibo_id, :default => 0, :null => false
      t.integer :rt_count, :default => 0
      t.integer :reply_count, :default => 0
      t.integer :article_id, :default => 0
      t.integer :weibo_type, :limit => 4, :default => 0
      t.integer :content_type, :limit => 4, :default => 0
      t.timestamps
    end

    add_index :weibos, [:owner_id, :owner_type]
  end

  def self.down
    drop_table :weibos
  end
end
