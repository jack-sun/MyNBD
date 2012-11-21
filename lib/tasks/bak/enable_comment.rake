#encoding:utf-8
namespace :articles do
  task :enable_comment => :environment do
    
    begin_at = Time.now
    
    puts "-----Settings.host: #{Settings.host}"
    puts "-----Rails env: #{Rails.env}"
    last_id = ENV['last_id']
    puts "-----last_id: #{last_id}" #616979
    
    
    Article.find_each(:conditions => ["id >= ?", last_id], :batch_size => 100) do|a|
      begin
        if a.columns.blank?
          puts "current article have no columns: #{a.id}"
          next
        end
        
        columns = a.columns.map(&:root).uniq
        
        if a.weibo.nil?
          first_column = columns.shift
          weibo_content = "【#{a.title}】#{a.show_digest} <a href='#{Settings.host}/articles/#{a.id}'>查看详情</a>"
          ori_weibo = first_column.user.create_plain_text_weibo(weibo_content)
          Weibo.weibo_article_id[ori_weibo.id] = a.id
          
          columns.each do |c|
            c.user.rt_weibo(ori_weibo, :content => Weibo::DEFAULT_RT_CONENT)
          end
          
          Article.update_all(["weibo_id = ?, allow_comment = ?", ori_weibo.id, 1], ["id = ?", a.id])
          
          puts "finish article id: #{a.id},   url: #{Settings.host}/articles/#{a.id}"
        else
          puts "already enaabled: #{a.id}"
        end
      
      rescue
        puts "enable comment error msg: #{$!}"
        next
      end
      
    end
    
    puts "enable comment time cost: #{Time.now - begin_at}"
  end
  
  
end
