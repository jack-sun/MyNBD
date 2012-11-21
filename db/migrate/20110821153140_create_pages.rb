class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :article_id, :null => false
      t.text :content, :null => false
      t.integer :image_id
      t.string :video
      t.integer :p_index, :default => 1

      t.timestamps
    end

    add_index :pages, :article_id
  end

  def self.down
    drop_table :pages
  end
end
