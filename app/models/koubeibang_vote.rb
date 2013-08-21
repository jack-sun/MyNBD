class KoubeibangVote < ActiveRecord::Base

  set_table_name "kbb_votes"

  belongs_to :koubeibang_account, :foreign_key => "kbb_account_id"
  belongs_to :koubeibang_candidate, :foreign_key => "kbb_candidate_id"

  NORMAL_CANDIDATE_VOTES = 1
  APPEND_CANDIDATE_VOTES = 2

  attr_accessible :kbb_candidate_id, :kbb_account_id, :append_candidate

  class << self

    def vote_candidates(index)
      range = KoubeibangCandidate::VOTE_LIST_IDS[KoubeibangCandidate.const_get("VOTE_LIST#{index}")]
      candidates = KoubeibangCandidate.where(:id => range).includes(:koubeibang_candidate_details)
      candidates
    end

    def get_votes_from_params(params)
      params["vote_candidates"]
    end

    def vote_type_to_num(vote_type)
      return vote_type == NORMAL_CANDIDATE_VOTES ? 1 : 10
    end

    def generate_votes(kbbs, params, remote_ip, kbb_account)
      kbbs.each do |kbb|
        kbb_params = params["koubeibang_#{kbb.id}"]
        votes = KoubeibangVote.get_votes_from_params(kbb_params).map(&:to_i)
        votes_candidates = votes.map { |vote| KoubeibangCandidate.where(:id => vote).first }
        pending_vote_candidates = []
        Koubeibang.get_candidates_from_params(kbb_params) do |candidate|
          pending_vote_candidates << candidate unless pending_vote_candidates.include?(candidate)
        end
        Koubeibang.transaction do
          candidates = pending_vote_candidates.map { |candidate| kbb.generate_candidate!(candidate, remote_ip, kbb_account) }
          candidates -= votes_candidates & candidates
          candidates.each { |vote_candidate| vote_candidate.generate_vote!(kbb_account, KoubeibangVote::APPEND_CANDIDATE_VOTES) }
          votes_candidates.each { |vote_candidate| vote_candidate.generate_vote!(kbb_account, KoubeibangVote::NORMAL_CANDIDATE_VOTES) }
        end
      end
    end

  end

end
