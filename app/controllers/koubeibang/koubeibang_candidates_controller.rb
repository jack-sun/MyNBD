require "nbd/koubeibang_utils"

class Koubeibang::KoubeibangCandidatesController < Koubeibang::KoubeibangBaseController

  before_filter :init_kbb_thumbed_cookies, :only => [:index, :thumb_up, :thumb_down]
  before_filter :auth_candidate_thumbed, :only => [:thumb_up, :thumb_down]
  before_filter :init_koubeibang_candidate, :only => [:thumb_up, :thumb_down]
  after_filter  :append_thumbed_cookies, :only => [:thumb_up, :thumb_down]
  before_filter :init_current_year_kbbs, :only => [:create]

  def index
    @kbbs = Koubeibang.this_year.includes(:koubeibang_candidates)
  end

  def create
    KoubeibangCandidate.generate_candidates(@kbbs, params, request.ip)
    redirect_to success_koubeibangs_url and return
  end

  def thumb_up
    render :json => @koubeibang_candidate.increase_thumb_up_count and return if @koubeibang_candidate.present?
  end

  def thumb_down
    render :json => @koubeibang_candidate.increase_thumb_down_count and return if @koubeibang_candidate.present?
  end

  private

  include Nbd::KoubeibangUtils

  def auth_candidate_thumbed
    render :json => KoubeibangCandidate::UPDATE_FAILED and return if @ori_cookies.present? && @ori_cookies.include?(params[:id])
  end

  def append_thumbed_cookies
    cookies[:kbb_thumbed] = { :value => encode_thumbed_cookies(@ori_cookies << params[:id]), :expires => 1.days.from_now }
  end

  def init_koubeibang_candidate
    @koubeibang_candidate = KoubeibangCandidate.where(:id => params[:id]).first
  end

  def init_kbb_thumbed_cookies
    @ori_cookies = cookies[:kbb_thumbed].present? ? decode_thumbed_cookies(cookies[:kbb_thumbed]) : []
  end

end
