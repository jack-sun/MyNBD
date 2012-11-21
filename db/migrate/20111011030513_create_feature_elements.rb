class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :feature_elements do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :feature_elements
  end
end
