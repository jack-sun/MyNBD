class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name, :limit => 32, :null => false, :unique => true
      t.string :code, :limit => 32, :null => false, :unique => true
      t.integer :followers_count, :defalut => 0
      t.integer :weibos_count, :defalut => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
