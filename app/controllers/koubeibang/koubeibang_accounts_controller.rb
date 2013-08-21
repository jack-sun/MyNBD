class Koubeibang::KoubeibangAccountsController < Koubeibang::KoubeibangBaseController

  before_filter :auth_kbb_account
  before_filter :init_kbb_account
  before_filter :auth_kbb_account_fin_info

  def update
    if @kbb_account.update_attributes(params[:koubeibang_account])
      redirect_to new_koubeibang_vote_url
    else
      render :edit
    end
  end

  private

  def init_kbb_account
    @kbb_account = current_kbb_account
  end

  def auth_kbb_account_fin_info
    kbb_account = current_kbb_account
    if (kbb_account.phone_no && kbb_account.real_name && kbb_account.email && kbb_account.inviter && kbb_account.declaration).present?
      redirect_to new_koubeibang_vote_url and return 
    end
  end

end
