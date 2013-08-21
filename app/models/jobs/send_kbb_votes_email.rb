class Jobs::SendKbbVotesEmail
  @queue = :koubeibang
  def self.perform(kbb_account_id)
    kbb_account = KoubeibangAccount.where(:id => kbb_account_id).first
    kbb_account.export_vote_result
    UserMailer.report_kbb_vote(kbb_account.company_name).deliver
    kbb_account.sended_email!
  end
end