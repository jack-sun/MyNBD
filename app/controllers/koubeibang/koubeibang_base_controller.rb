# encoding: utf-8
class Koubeibang::KoubeibangBaseController < ApplicationController

  layout "koubeibang"

  protected

  def init_current_year_kbbs
    @kbbs = Koubeibang.this_year
  end

  def current_kbb_account
    KoubeibangAccount.where(:id => session[:kbb_account_id]).first
  end

  helper_method :current_kbb_account

  def signed_in?
    session[:kbb_account_id].present?
  end

  def auth_kbb_account
    redirect_to new_koubeibang_session_url, :alert => "您必须登录" and return unless signed_in?
  end

end