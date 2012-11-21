class CreateTagsWeibos < ActiveRecord::Migration
  def self.up
    create_table :tags_weibos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :tag_id, :null => false
      t.integer :weibo_id, :null => false

      t.timestamps
    end

    add_index :tags_weibos, :tag_id
    add_index :tags_weibos, :weibo_id
  end

  def self.down
    drop_table :tags_weibos
  end
end
