class Koubeibang::KoubeibangCandidateDetailsController < Koubeibang::KoubeibangBaseController

  def index
    @kbb_candidate_details = KoubeibangCandidateDetail.includes(:koubeibang_candidate, {:koubeibang_candidate => :koubeibang}) \
                                                      .where('comment <> ? and comment_status = ?', '', KoubeibangCandidateDetail::PUBLISHED) \
                                                      .order('id desc') \
                                                      .page(params[:page]).per(10)
  end

end
