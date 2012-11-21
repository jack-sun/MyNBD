class ColumnsUser < ActiveRecord::Base
  belongs_to :column
  belongs_to :user
end
