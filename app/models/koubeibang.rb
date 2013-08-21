class Koubeibang < ActiveRecord::Base

  set_table_name "kbbs"

  has_many :koubeibang_candidates, :foreign_key => "kbb_id"

  attr_accessible :k_index, :title, :desc, :kbb_candidates_count

  scope :this_year, where(:k_index => Time.now.year.to_s)

  def generate_candidate!(candidate, remote_ip, kbb_account = nil)
    return unless candidate["stock_company"].present? && candidate["stock_code"].present?
    comment = candidate.delete("comment")
    if (koubeibang_candidate = KoubeibangCandidate.where(:kbb_id => self.id, :stock_code => candidate["stock_code"]).first).blank?
      koubeibang_candidate = self.koubeibang_candidates.new(candidate)
      koubeibang_candidate.save!
    else
      koubeibang_candidate.update_attributes!(:stock_company => candidate["stock_company"])
      koubeibang_candidate.koubeibang.increase_kbb_candidates_count!
    end
    koubeibang_candidate.generate_candidate_detail!(comment, remote_ip, kbb_account)
    return koubeibang_candidate
  end

  def increase_kbb_candidates_count!
    self.update_attributes!(:kbb_candidates_count => (self.kbb_candidates_count + 1))
  end

  class << self

    def candidates_invalid?(candidates)
      get_candidates_from_params(candidates) do |candidate|
        koubeibang_candidate = KoubeibangCandidate.new(:stock_company => candidate["stock_company"], 
                                                       :stock_code => candidate["stock_code"])
        return false if koubeibang_candidate.valid?
      end
      return true
    end

    def get_candidates_from_params(params)
      params.each_with_index do |hash, index|
        return if hash.first == "vote_candidates"
        candidate = hash.last
        yield(candidate, index)
      end  
    end

  end

end
