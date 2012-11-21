class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :image, :null => false
      t.integer :i_type, :size => 4, :default => 0
      t.text :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
