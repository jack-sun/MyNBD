class Jobs::MakeServiceCards
  @queue = :make_service_cards_queue

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
  
  def self.perform card_task
    card_task = CardTask.where(:id => card_task).first
    card_task.update_attributes!(:proceed => CardTask::PROCEED_PROCESSING)
    CardTask.transaction do
      begin
        card_task.card_sub_tasks.each do |card_sub_task|
            # if card_sub_task.service_cards.present?
            #   card_sub_task.service_cards.each { |service_card| service_card.update_attributes! :status => ServiceCard::STATUS_UNACTIVATED }
            # else
              card_sub_task.service_card_count.times do
                card_no, password = ServiceCard.generate_card_number_and_password
                card = card_sub_task.service_cards.new(:card_no => card_no, :password => password, 
                                                       :card_type => card_sub_task.service_card_type, 
                                                       :plan_type => card_sub_task.service_card_plan_type, 
                                                       :status => ServiceCard::STATUS_UNACTIVATED, 
                                                       :staff_id => card_task.create_staff.id, 
                                                       :review_staff_id => card_task.reviewed_staff.id)
                card.save!
                card_task.proceed_amount.increment
              end
            # end
            # card_sub_task.update_attributes!(:proceed => CardSubTask::PROCEED_FINISHED)
          # end
        end
        card_task.update_attributes!(:proceed => CardTask::PROCEED_FINISHED)
      rescue ActiveRecord::Rollback
        card_task.update_attributes!(:proceed => CardTask::PROCEED_ERROR)
      end
    end
  end
end

