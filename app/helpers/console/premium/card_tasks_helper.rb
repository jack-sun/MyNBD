#encoding: utf-8
module Console::Premium::CardTasksHelper
  def options_for_ttyj_service_card_plan_type
    ttyj_service_card_plan_type_options = []
    ServiceCard::TIME_TYPE.each { |k, v| ttyj_service_card_plan_type_options << ["#{v}个月", k] }
    return ttyj_service_card_plan_type_options
  end

  def options_for_gms_service_card_plan_type
    gms_service_card_plan_type_options = []
    GmsAccount::PLAN_TYPE.each { |k, v| gms_service_card_plan_type_options << [v, k] }
    return gms_service_card_plan_type_options
  end

  def options_for_service_card_type
    service_card_type_options = []
    ServiceCard::CARD_TYPES.each { |k, v| service_card_type_options << [v, k] }
    return service_card_type_options
  end

  def card_sub_task_service_card_type service_card_type
    ServiceCard::CARD_TYPES[service_card_type]
  end

  def card_sub_task_service_card_plan_type service_card_type, service_card_plan_type
    if service_card_type == ServiceCard::CARD_TYPE_TTYJ
      "#{ServiceCard::TIME_TYPE[service_card_plan_type]}个月"
    elsif service_card_type == ServiceCard::CARD_TYPE_GMS
      "#{GmsAccount::PLAN_TYPE[service_card_plan_type]}"
    end
  end

  def sub_comment comment
    comment.length > 14 ? (comment[0...14] + (link_to_function ' 更多', "javascript:;", :class => "tzbctExpandComment")).html_safe : comment
  end


  def card_task_detail card_task
    details = ""
    card_task.card_sub_tasks.each do |card_sub_task|
      detail = []
      detail << card_sub_task.converted_service_card_type
      detail << card_sub_task.converted_service_card_plan_type
      detail << "#{card_sub_task.service_card_count}张"
      details << (content_tag(:p, link_to_if(card_task.proceed == CardTask::PROCEED_FINISHED, detail.join(" "), show_cards_console_premium_card_task_card_sub_task_url(card_task, card_sub_task)), "data-link" => show_cards_console_premium_card_task_card_sub_task_url(card_task, card_sub_task)))
    end
    return details.html_safe
  end

  def card_task_process_status status
    return CardTask::PROCEED_TYPE status
  end
end
