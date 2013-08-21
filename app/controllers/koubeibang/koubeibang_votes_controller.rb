class Koubeibang::KoubeibangVotesController < Koubeibang::KoubeibangBaseController

  before_filter :auth_kbb_account
  before_filter :auth_kbb_account_can_vote
  before_filter :auth_kbb_account_voted, :except => [:download_results, :success]
  before_filter :auth_kbb_account_should_vote, :only => [:download_results, :success]
  before_filter :init_current_year_kbbs
  before_filter :init_vote_candidates, :only => [:new]

  def create
    unless votes_params_vaild?
      init_vote_candidates
      render :new and return
    else
      KoubeibangVote.generate_votes(@kbbs, params, request.ip, current_kbb_account)
      redirect_to success_koubeibang_votes_url
    end
  end

  def download_results
    return unless current_kbb_account.id == params[:id].to_i
    file_path = current_kbb_account.export_basic_info
    if file_path.present?
      send_file(file_path)
      Resque.enqueue(Jobs::SendKbbVotesEmail, current_kbb_account.id) unless current_kbb_account.sended_mail
    else
      render :success and return
    end
  end

  private

  def init_vote_candidates
    @kbbs.each_with_index do |kbb, index|
      instance_variable_set("@kbb_#{kbb.id}_vote_candidates", KoubeibangVote.vote_candidates(index + 1))
    end
  end

  def votes_params_vaild?
    @kbbs.each do |kbb|
      kbb_params = params["koubeibang_#{kbb.id}"]
      Koubeibang.get_candidates_from_params(kbb_params) do |candidate|
        candidate.delete_if { |k, v| v.blank? }  
        return false if candidate.size != 3
      end
      return false if KoubeibangVote.get_votes_from_params(kbb_params).size != 12
    end
    return true
  end

  def auth_kbb_account_voted
    redirect_to(success_koubeibang_votes_url) and return if current_kbb_account.voted?
  end

  def auth_kbb_account_should_vote
    redirect_to new_koubeibang_vote_url and return unless current_kbb_account.voted?
  end

  def auth_kbb_account_can_vote
    kbb_account = current_kbb_account
    if (kbb_account.phone_no && kbb_account.real_name && kbb_account.email && kbb_account.inviter && kbb_account.declaration).blank?
      redirect_to edit_koubeibang_account_url(session[:kbb_account_id]) and return
    end
  end

end
