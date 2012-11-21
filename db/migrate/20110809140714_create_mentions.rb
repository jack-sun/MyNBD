class CreateMentions < ActiveRecord::Migration
  def self.up
    create_table :mentions, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :null => false
      t.integer :target_id, :null => false
      t.string :target_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :mentions
  end
end
