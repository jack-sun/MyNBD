class CreateArticlesChildren < ActiveRecord::Migration
  def self.up
    create_table :articles_children, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :article_id, :null => false
      t.integer :children_id, :null => false
      t.integer :pos, :null => false, :default => 1

      t.timestamps
    end

    add_index :articles_children, :article_id
    add_index :articles_children, :children_id
  end

  def self.down
    drop_table :articles_children
  end
end
