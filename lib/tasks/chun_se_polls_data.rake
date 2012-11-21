#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :polls do
  task :chun_se_polls_data => :environment do
    poll_id = ENV['poll_id'].to_i
    puts "poll_id: #{poll_id}"

    votes = ENV['votes'].split(',')
    puts "votes after: #{votes}"

    p = Poll.find(poll_id) 
    p.polls_options.order('id asc').each_with_index{|e, index| e.vote_count = votes[index]; e.save!}
    p.total_vote_count = votes.inject(0){|sum, e| sum += e.to_i}
    p.save!
  end
end
