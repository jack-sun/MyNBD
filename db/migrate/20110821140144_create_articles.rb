class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :title, :null => false
      t.string :list_title
      t.string :sub_title
      t.string :digest, :limit => 300
      t.integer :a_type, :limit => 4, :null => false, :default => 0
      t.string :slug, :limit => 32, :null => false
      t.string :redirect_to
      t.string :ori_author, :limit => 64
      t.string :ori_source, :limit => 64
      t.string :comment, :limit => 300
      t.integer :image_id
      t.integer :click_count, :default => 0
      t.integer :max_child_pos, :default => 0, :null => false
      t.integer :allow_comment, :limit => 4, :default => 1
      t.integer :status, :limit => 4, :default => 0
      t.integer :is_rollowing_news, :limit => 4, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
