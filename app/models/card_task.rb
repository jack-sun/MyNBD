#encoding: utf-8
class CardTask < ActiveRecord::Base

  include Redis::Objects
  counter :proceed_amount
  value :total_amount

  has_many :card_sub_tasks
  belongs_to :create_staff, :class_name => "Staff", :foreign_key => :staff_id
  belongs_to :reviewed_staff, :class_name => "Staff", :foreign_key => :review_staff_id

  STATUS_UNREVIEW = 0
  STATUS_REVIEWED = 1

  STATUS_TYPE = { STATUS_UNREVIEW => "待审核", STATUS_REVIEWED => "已通过" }

  # PROCEED_UNFINISHED = 0
  # PROCEED_FINISHED = 1

  # PROCEED_TYPE = { PROCEED_UNFINISHED => "未进行", PROCEED_FINISHED => "已完成" }

  PROCEED_UNFINISHED = 0
  PROCEED_FINISHED = 1
  PROCEED_ERROR = 2
  PROCEED_PROCESSING = 3

  PROCEED_TYPE = { PROCEED_UNFINISHED => "待生成卡号", PROCEED_FINISHED => "已生成卡号", 
                   PROCEED_ERROR => "卡号生成错误", PROCEED_PROCESSING => "正在生成卡号" }
  
  attr_accessible :staff_id, :review_staff_id, :comment, :status, :proceed, :card_sub_tasks_attributes
  accepts_nested_attributes_for :card_sub_tasks

  def make_card
    # CardTask.transaction do
    #   card_sub_tasks.each do |card_sub_task|
    #     if card_sub_task.service_cards.present?
    #       card_sub_task.service_cards.each { |service_card| service_card.update_attributes! :status => ServiceCard::STATUS_UNACTIVATED }
    #     else
    #       card_sub_task.make_card create_staff.id, reviewed_staff.id
    #     end
    #     card_sub_task.update_attributes!(:proceed => CardSubTask::PROCEED_FINISHED)
    #   end
    #   self.update_attributes!(:proceed => PROCEED_FINISHED)
    # end
    Resque.enqueue(Jobs::MakeServiceCards, id) unless proceed == PROCEED_PROCESSING
  end

  def unreview
    # CardTask.transaction do
    #   card_sub_tasks.each do |card_sub_task|
    #     card_sub_task.service_cards.each { |card| card.update_attributes! :status => ServiceCard::STATUS_UNREVIEW, 
    #                                                                       :review_staff_id => nil } 
    #     card_sub_task.update_attributes! :proceed => CardSubTask::PROCEED_UNFINISHED
    #   end
    update_attributes(:status => CardTask::STATUS_UNREVIEW, :review_staff_id => nil, :proceed => CardTask::PROCEED_UNFINISHED)
    # end
  end

  def service_cards
    service_cards = []
    card_sub_tasks.each { |card_sub_task| service_cards << card_sub_task.service_cards } 
    return service_cards.flatten
  end

  # def process_status
  #   status = card_sub_tasks.map(&:proceed)
  #   if status.include? CardSubTask::PROCEED_PROCESSING
  #     return CardSubTask::PROCEED_PROCESSING
  #   else
  #     if status.include? CardSubTask::PROCEED_FINISHED
  #       return CardSubTask::PROCEED_FINISHED
  #     elsif status.include? CardSubTask::PROCEED_ERROR
  #       return CardSubTask::PROCEED_ERROR
  #     end
  #   end
  # end

  def progress_percentage
    total_amount = 0
    # proceed_amount = 0
    total_amount = card_sub_tasks.map(&:service_card_count).reduce(:+)
    # card_sub_tasks.each do |card_sub_task|
    #   if card_sub_task.proceed == CardSubTask::PROCEED_FINISHED || card_sub_task.proceed == CardSubTask::PROCEED_ERROR
    #     proceed_amount += card_sub_task.service_card_count
    #   elsif card_sub_task.proceed == CardSubTask::PROCEED_PROCESSING
    #     proceed_amount += card_sub_task.service_cards.count
    #   end
    # end
    return percentagere = "#{sprintf("%.1f", proceed_amount.to_i / total_amount.to_f * 100)}%"
  end

  def converted_status
    CardTask::STATUS_TYPE[status]
  end

  def converted_proceed
    CardTask::PROCEED_TYPE[proceed]
  end

end
