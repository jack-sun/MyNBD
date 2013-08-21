# encoding: utf-8
class UserMailer < ActionMailer::Base
  default :from => "info@nbd.com.cn"
  
  def welcome_email(user)
    @user = user
    @url  = root_url
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site")
  end
  
  def password_reset(user)
    @user = user
    mail(:to => user.email, :subject => "密码重置")
  end
  
  def activate_user(user)
    @user = user
    mail(:to => user.email, :subject => "激活用户")
  end

  def ttyj_weekly_active_user(recipients)
    last_week_time = Time.now - 1.week
    @start_date = last_week_time.beginning_of_week.strftime("%Y-%m-%d")
    @end_date = last_week_time.end_of_week.strftime("%Y-%m-%d")
    @active_users = Redis::HashKey.new("#{MnAccount::ACTIVE_USER}", Redis::Objects.redis)
    @mn_accounts = MnAccount.where(:id => @active_users.keys)
    @subject = "[投资宝] 天天赢家-活跃用户上周（#{@start_date} ~ #{@end_date}）统计"
    mail(:to => recipients, :subject => @subject)
  end

  def report_kbb_vote(company_name)
    attachments["#{company_name} 口碑榜投票结果.xls"] = File.read("#{Rails.root}/tmp/#{company_name}_结果_回执单.xls")
    mail(:to => 'winterwhisper.dev@gmail.com', :subject => "#{company_name} 口碑榜投票结果")
  end
  
end
