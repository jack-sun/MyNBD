class CreateColumns < ActiveRecord::Migration
  def self.up
    create_table :columns, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false
      t.integer :parent_id
      t.integer :max_pos, :default => 0, :null =>false

      t.timestamps
    end
  end

  def self.down
    drop_table :columns
  end
end
