#encoding:utf-8
class PollsController < ApplicationController
  #before_filter :authorize #, :only => [:create, :destroy, :rt, :fetch_new, :ban, :unban]
  include SimpleCaptcha::ControllerHelpers

  after_filter :only => [:vote] do
    Rails.logger.debug "-------------------------------------------------#{session.inspect}"
  end

  def vote
    @poll = Poll.find(params[:id])

    if @poll.expiried?
      return render :text => "投票已结束"
    end

    # for google recaptcha
    #if @poll.need_capcha? and !verify_recaptcha
    #
    if @poll.need_capcha? and !simple_captcha_valid?("captcha_poll_#{@poll.id}")
      return render :js => "alert('验证码错误')"
    end

    #session[:_csrf_token] = nil

    if voted_for_poll?(@poll)
    else
      poll_options = params[:vote_option_ids].split(",")
      PollsOption.update_all("vote_count = vote_count+1", :id => poll_options)
      @poll.increment!(:total_vote_count, poll_options.count)
      case @poll.repeats_verify_type
      when Poll::VERIFY_TYPE_IP
        PollsLog.create(:poll_id => @poll.id, :remote_ip => request.remote_ip)
      when Poll::VERIFY_TYPE_LOGIN
        PollsLog.create(:poll_id => @poll.id, :user_id => current_user.id, :remote_ip => request.remote_ip)
      end
    end

    cookies["vote_#{@poll.id}"] = 1
    @voted_success = true
  end

  def result
    @poll = Poll.find(params[:id])
    render :vote    
  end

  private

  def voted_for_poll?(poll)
    return true if cookies["vote_#{poll.id}"] == "1" 
    case poll.repeats_verify_type
    when Poll::VERIFY_TYPE_IP
      return true if poll.vote_by_this_ip?(request.remote_ip)
    when Poll::VERIFY_TYPE_LOGIN
      return true if poll.vote_by_this_ip?(request.remote_ip)
      return true if current_user and poll.vote_by_this_user?(current_user.id)
    else
      return false
    end
  end

end
