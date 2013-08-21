#encoding:utf-8
class KoubeibangCandidateDetail < ActiveRecord::Base

  set_table_name "kbb_candidate_details"

  belongs_to :koubeibang_candidate, :foreign_key => "kbb_candidate_id", :counter_cache => "kbb_candidate_details_count"
  
  attr_accessible :comment, :comment_status, :remote_ip, :kbb_account_id

  PUBLISHED = 1
  BANNDED = 2

  STATUS = {PUBLISHED => "已通过", BANNDED => "未通过"}

  def is_banned?
    comment_status == BANNDED
  end

  def koubeibang_title
    koubeibang_candidate.koubeibang.title
  end
end
