class LiveAnswersController < ApplicationController
  before_filter :authorize
  def index
    
  end

  def create
    @live_talk = LiveTalk.where(:id => params[:live_talk_id]).first
    return render :text => "faild" unless @live_talk
    if @live_answer = @current_user.create_live_answers(@live_talk, params[:live_answer])
      @live = @live_talk.live
      @is_compere = @current_user.try(:id).to_i == @live.try(:user_id)
      Live.update_timeline(@live.id, Time.now)
    else
      return render :text => "faild" unless @live_talk
    end
  end

  def destroy
    @live_answer = LiveAnswer.find(params[:id])
    @live_answer.destroy
    render :js => "$('div#weibo_#{@live_answer.weibo_id}').fadeOut(1000).remove()"
  end
end
