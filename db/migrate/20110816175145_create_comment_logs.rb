class CreateCommentLogs < ActiveRecord::Migration
  def self.up
    create_table :comment_logs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :null => false
      t.integer :comment_id, :null => false

      t.timestamps
    end

    add_index :comment_logs, :user_id
    add_index :comment_logs, :comment_id
  end

  def self.down
    drop_table :comment_logs
  end
end
