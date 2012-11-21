class CreateFeaturePages < ActiveRecord::Migration
  def self.up
    create_table :feature_pages do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :feature_pages
  end
end
