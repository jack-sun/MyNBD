class StaffsPermission < ActiveRecord::Base
  belongs_to :staff
  belongs_to :column

end


# == Schema Information
#
# Table name: staffs_permissions
#
#  id         :integer(4)      not null, primary key
#  column_id  :integer(4)      not null
#  staff_id   :integer(4)      not null
#  creator_id :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

