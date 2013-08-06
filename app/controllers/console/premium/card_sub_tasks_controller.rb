class Console::Premium::CardSubTasksController < ApplicationController

  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console

  def show_cards
    @service_card_type = true
    @service_card_type = "create"
    @card_task = CardTask.where(:id => params[:card_task_id]).first
    @card_sub_task = CardSubTask.where(:id => params[:id]).first

    @stats_type = params[:type] || ServiceCard::STATUS_UNACTIVATED.to_s
    service_cards = @card_sub_task.service_cards.select { |service_card| service_card.status.to_s == @stats_type }
    @service_cards = Kaminari.paginate_array(service_cards).page(params[:page]).per(20)
    render :template => "console/premium/service_cards/index" and return
  end

end
