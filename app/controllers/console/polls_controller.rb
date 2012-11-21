class Console::PollsController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console

  def index
    @polls = Poll.all
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = @current_staff.polls.new(params[:poll])
    if @poll.save!
      if request.xhr?
        render :text => @poll.id
      else
        redirect_to console_polls_path
      end
    else
      render :new
    end
  end

  def edit
    @poll = Poll.find(params[:id])
  end

  def update
    @poll = Poll.find(params[:id])
    if @poll.update_attributes(params[:poll])
      if request.xhr?
        render :text => @poll.id
      else
        redirect_to console_polls_path
      end
    else
      render :edit
    end
  end

  def destroy
    @poll = Poll.find(params[:id])
    @poll.destroy
    redirect_to console_polls_path
  end
end
