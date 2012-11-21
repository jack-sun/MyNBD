class JiujiuaiPollRecord < ActiveRecord::Base
  belongs_to :polls_option, :foreign_key => :poll_option_id
end
