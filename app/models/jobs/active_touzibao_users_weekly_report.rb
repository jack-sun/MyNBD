class Jobs::ActiveTouzibaoUsersWeeklyReport
  @queue = :touzibao
  def self.perform
      UserMailer.ttyj_weekly_active_user(MnAccount::RECEIVE_ACTIVE_USER_EMAILS).deliver
      MnAccount.last_week_user_activity_cache_flush!
  end
end
