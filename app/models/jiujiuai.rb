class Jiujiuai
  def self.perform
    t = Time.now
    poll_options = PollsOption.where(:poll_id => 55)
    poll_options.each do |poll_option|
      JiujiuaiPollRecord.create({:poll_option_id => poll_option.id, :record_at => t, :current_vote_count => poll_option.vote_count, :poll_id => poll_option.poll_id})
    end
  end
end
