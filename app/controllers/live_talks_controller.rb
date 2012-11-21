#encoding:utf-8
class LiveTalksController < ApplicationController
  before_filter :authorize
  def create
    @question_page = params[:live_talk][:question_page].try(:to_i) == 1
    params[:live_talk].delete(:question_page)
    if @live_talk = @current_user.create_live_talk(params[:live_talk])
      @live = @live_talk.live
      @is_compere = @current_user.is_important_user_of?(@live)
    else
      render :text => "faild"
    end
  end

  def destroy
    @live_talk = LiveTalk.find(params[:id])
    @live_talk.destroy
    render :js => "$('li#talk_#{@live_talk.id}').fadeOut(1000).remove()"
  end

  def ban
    @live_talk = LiveTalk.find(params[:id]) 
    @live = @live_talk.live
    return render :text => "faild" unless @current_user.is_important_user_of?(@live)

    @live_talk.to_ban!
    render :js => "$('#weibo_#{@live_talk.weibo_id}').find('.banButton').attr('href', '#{unban_live_talk_url(@live_talk)}').text('解除屏蔽')"
  end

  def unban
    @live_talk = LiveTalk.find(params[:id]) 
    @live = @live_talk.live
    return render :text => "faild" unless @current_user.is_important_user_of?(@live)

    @live_talk.to_unban!
    render :js => "$('#weibo_#{@live_talk.weibo_id}').find('.banButton').attr('href', '#{ban_live_talk_url(@live_talk)}').text('屏蔽')"
  end
end
