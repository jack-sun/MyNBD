#encoding:utf-8
namespace :ad_positions do
  task :add_new_pos_01_10 => :environment do
    init_arr = [
                  ["智库首页", "d-1", 700,70], 
                  ["智库首页", "d-2", 610,90], 
                  ["智库首页", "d-3", 300,300], 
                  ["智库首页", "d-4", 950,90], 
                ]
    init_arr.each do |ad_p|
      AdPosition.create(:name => ad_p[1], :desc => ad_p[0], :width => ad_p[2], :height => ad_p[3], :current_ad_id => 0, :price => 0)
    end
  end
end
