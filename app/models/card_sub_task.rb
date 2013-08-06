#encoding: utf-8
class CardSubTask < ActiveRecord::Base

  belongs_to :card_task
  has_many :service_cards, :class_name => "ServiceCard", :foreign_key => "task_id"

  # PROCEED_UNFINISHED = 0
  # PROCEED_FINISHED = 1
  # PROCEED_ERROR = 2
  # PROCEED_PROCESSING = 3

  # PROCEED_TYPE = { PROCEED_UNFINISHED => "待执行", PROCEED_FINISHED => "已完成", 
  #                  PROCEED_ERROR => "执行错误", PROCEED_PROCESSING => "正在执行" }

  attr_accessible :service_card_type, :service_card_plan_type, :service_card_count, :proceed

  validates :service_card_type, :inclusion => { :in => ServiceCard::CARD_TYPES.keys }
  validates :service_card_plan_type, :inclusion => { :in => (ServiceCard::TIME_TYPE.keys + GmsAccount::PLAN_TYPE.keys).uniq }
  validates :service_card_count, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 } 

  # def make_card create_staff, reviewed_staff
  #   CardSubTask.transaction do
  #     service_card_count.times do
  #       card_no, password = ServiceCard.generate_card_number_and_password
  #       card = self.service_cards.new(:card_no => card_no, :password => password, :card_type => service_card_type, 
  #                                     :plan_type => service_card_plan_type, :status => ServiceCard::STATUS_UNACTIVATED, 
  #                                     :staff_id => create_staff, :review_staff_id => reviewed_staff)
  #       card.save!
  #     end
  #     self.update_attributes!(:proceed => PROCEED_FINISHED)
  #   end
  # end

  def converted_service_card_type
    ServiceCard::CARD_TYPES[service_card_type]
  end

  def converted_service_card_plan_type
    if service_card_plan_type == ServiceCard::CARD_TYPE_TTYJ
      "#{ServiceCard::TIME_TYPE[service_card_type]}个月"
    elsif service_card_plan_type == ServiceCard::CARD_TYPE_GMS
      GmsAccount::PLAN_TYPE[service_card_plan_type]
    end
  end

end
