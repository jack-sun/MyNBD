#encoding:utf-8
namespace :badkeywords do
  task :init => :environment do
    words_arr = File.new(File.expand_path("../../shared/badkeywords.txt", File.dirname(__FILE__)), "r:utf-8").read.split("\n")
    words_arr.each do |word|
      puts "------------- #{word}--------------#{word.encoding}"
      Badkeyword.create(:value => word.strip.force_encoding("utf-8").gsub("*", "\*"), :staff_id => 49)
    end
    puts "----------finish: bad words count :#{words_arr.size}------------------"
  end
end
