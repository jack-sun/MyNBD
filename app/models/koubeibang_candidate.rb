class KoubeibangCandidate < ActiveRecord::Base

  set_table_name "kbb_candidates"

  belongs_to :koubeibang, :foreign_key => "kbb_id", :counter_cache => "kbb_candidates_count"
  has_many :koubeibang_candidate_details, :foreign_key => "kbb_candidate_id", :dependent => :destroy
  has_many :koubeibang_votes, :foreign_key => "kbb_candidate_id"

  UPDATE_FAILED = -1

  VOTE_LIST1 = 1
  VOTE_LIST2 = 2
  VOTE_LIST3 = 3
  VOTE_LIST4 = 4
  VOTE_LIST5 = 5
  VOTE_LIST6 = 6
  VOTE_LIST7 = 7
  VOTE_LIST8 = 8

  VOTE_LIST_IDS = {
    VOTE_LIST1 => Koubeibang.this_year.includes(:koubeibang_candidates)[0].koubeibang_candidates.first(50).map(&:id), 
    VOTE_LIST2 => Koubeibang.this_year.includes(:koubeibang_candidates)[1].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST3 => Koubeibang.this_year.includes(:koubeibang_candidates)[2].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST4 => Koubeibang.this_year.includes(:koubeibang_candidates)[3].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST5 => Koubeibang.this_year.includes(:koubeibang_candidates)[4].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST6 => Koubeibang.this_year.includes(:koubeibang_candidates)[5].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST7 => Koubeibang.this_year.includes(:koubeibang_candidates)[6].koubeibang_candidates.first(50).map(&:id),
    VOTE_LIST8 => Koubeibang.this_year.includes(:koubeibang_candidates)[7].koubeibang_candidates.first(50).map(&:id)
  }
  
  attr_accessible :stock_code, :stock_company, :thumb_up_count, :thumb_down_count, :kbb_votes_count

  validates :stock_code, :presence => true, :format => { :with => /^\d{6}$/ }
  validates :stock_company, :presence => true

  def generate_candidate_detail!(comment, remote_ip, kbb_account = nil)
    koubeibang_candidate_detail = self.koubeibang_candidate_details.new(:comment => comment, 
                                                                        :remote_ip => remote_ip, 
                                                                        :kbb_account_id => kbb_account.try(:id))
    koubeibang_candidate_detail.save!
  end

  def increase_thumb_up_count
    self.update_attributes(:thumb_up_count => self.thumb_up_count + 1) ? self.thumb_up_count : UPDATE_FAILED
  end

  def increase_thumb_down_count
    self.update_attributes(:thumb_down_count => self.thumb_down_count + 1) ? self.thumb_down_count : UPDATE_FAILED
  end

  def generate_vote!(kbb_account, vote_type)
    koubeibang_vote = self.koubeibang_votes.new(:kbb_account_id => kbb_account.id)
    koubeibang_vote.save!
    self.update_attributes!(:kbb_votes_count => self.kbb_votes_count + KoubeibangVote.vote_type_to_num(vote_type))
  end

  class << self

    def generate_candidates(kbbs, params, remote_ip)
      Koubeibang.transaction do
        kbbs.each do |kbb|
          Koubeibang.get_candidates_from_params(params["koubeibang_#{kbb.id}"]) do |candidate, index|
            kbb.generate_candidate!(candidate, remote_ip)
          end
        end
      end
    end

  end

end
