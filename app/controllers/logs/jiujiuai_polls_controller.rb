class Logs::JiujiuaiPollsController < ApplicationController
  
  USER_NAME = "jiujiuai_poll"
  PASSWORD = "toupiao500cd"
  if Rails.env.production?
    before_filter :authenticate
  end
 
  def result
    poll = Poll.find(params[:id])
    render :text => "No such poll !" if poll.blank?
    
    #poll_options = Poll.polls_options
    
    @date = params[:date] || Time.now.strftime("%Y-%m-%d")
    selected_records = JiujiuaiPollRecord.where(:poll_id => poll.id)
    selected_records = selected_records.where(["record_at >= ? AND record_at < ?", Time.parse(@date), Time.parse(@date) + 1.days]) if @date.present?
    
    @polls_options_records = selected_records.includes(:polls_option).to_a.group_by{|x| x.poll_option_id }
    @option_ids = PollsOption.where(:id => @polls_options_records.keys).order(" vote_count DESC").map(&:id)
    
  end
  
  private
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
  
end
