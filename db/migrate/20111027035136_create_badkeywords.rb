class CreateBadkeywords < ActiveRecord::Migration
  def self.up
    create_table :badkeywords do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :badkeywords
  end
end
