class LiveGuest < ActiveRecord::Base
  belongs_to :live
  belongs_to :guest, :class_name => "User", :foreign_key => "user_id"
end
