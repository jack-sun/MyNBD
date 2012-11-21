class Authentication < ActiveRecord::Base
  
  set_table_name "authentications"
  
  belongs_to :user
  
end

# == Schema Information
#
# Table name: authentications
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  provider   :string(255)     not null
#  uid        :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

