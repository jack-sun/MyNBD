#encoding: utf-8
class RecordActiveUserFilter
  def self.filter(controller)
    controller.current_mn_account.record_active_user
  end
end
