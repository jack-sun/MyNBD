module Console::ColumnPerformanceLogsHelper
  def option_for_charge_staff(current_staff)
    charge_staff_values = []
    Staff.where({:status => Staff::STATUS_ACTIVE, :user_type => [Staff::TYPE_EDITOR, Staff::TYPE_EDITOR_ADMIN]}).each do |staff| 
      charge_staff_values << [staff.real_name, staff.id.to_s]
    end
    options_for_select(charge_staff_values, current_staff)
  end


end
