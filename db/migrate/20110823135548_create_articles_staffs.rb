class CreateArticlesStaffs < ActiveRecord::Migration
  def self.up
    create_table :articles_staffs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :article_id, :null => false
      t.integer :staff_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :articles_staffs
  end
end
