class CreateArticlesColumns < ActiveRecord::Migration
  def self.up
    create_table :articles_columns, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :article_id, :null => false
      t.integer :column_id, :null => false
      t.integer :pos, :null => false, :default => 1

      t.timestamps
    end

    add_index :articles_columns, :article_id
    add_index :articles_columns, :column_id
  end

  def self.down
    drop_table :articles_columns
  end
end
