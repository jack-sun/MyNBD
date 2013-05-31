#encoding: utf-8
class StaffConvertLog < ActiveRecord::Base

  PENDING = 0
  APPROVED = 1

  STATUS = { PENDING => "待审核", APPROVED => "已审核" }

  belongs_to :staff
  belongs_to :charge_staff, :foreign_key => "staff_id_in_charge", :class_name => "Staff"
  
  attr_accessible :date_at, :convert_count, :status, :staff_id_in_charge, :comment

  validates_presence_of :date_at, :convert_count, :status
  validates :convert_count, :numericality => true
  validates :date_at, :format => { :with => /(\d*-)*\d*/ }
  validates :status, :inclusion => { :in => StaffConvertLog::STATUS.keys }
end
