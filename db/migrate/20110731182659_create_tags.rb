class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name, :limit => 64, :unique => true, :null => false
      t.integer :daily_count, :default => 0
      t.datetime :last_post_at

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
