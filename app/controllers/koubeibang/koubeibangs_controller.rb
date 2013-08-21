class Koubeibang::KoubeibangsController < Koubeibang::KoubeibangBaseController

  before_filter :init_current_year_kbbs, :only => [:new, :confirm]

  def confirm
    if candidates_valid?
      render :new and return
    else
      @kbbs.each { |kbb| init_koubeibang_confirm_page(kbb) }
    end
  end

  private

  def candidates_valid?
    results = []
    @kbbs.each { |kbb| results << Koubeibang.candidates_invalid?(params["koubeibang_#{kbb.id}"]) }
    results.include?(false) ? false : true
  end

  def init_koubeibang_confirm_page(kbb)
    Koubeibang.get_candidates_from_params(params["koubeibang_#{kbb.id}"]) do |candidate, index|
      generate_confirm_instance_variables(kbb, candidate, index)
    end
  end

  def generate_confirm_instance_variables(kbb, candidate, index)
    instance_variable_set("@kbb_#{kbb.id}_candidate_#{index + 1}_stock_code", candidate["stock_code"])
    instance_variable_set("@kbb_#{kbb.id}_candidate_#{index + 1}_stock_company", candidate["stock_company"])
    instance_variable_set("@kbb_#{kbb.id}_candidate_#{index + 1}_comment", candidate["comment"])
  end

end
