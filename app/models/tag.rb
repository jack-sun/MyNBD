class Tag < ActiveRecord::Base
  has_many :tags_weibos
  has_many :weibos, :through => :tags_weibos
  
  validates_uniqueness_of :name
  
  class << self
    def create_tags(tags=[])
      tags.map{|tag| find_or_create_by_name(tag)}
    end

  end
  
  def calculate_daily_count(hours=24)
    if Time.now.before?(self.last_post_at + hours.hours)
      self.daily_count += 1
    else
      self.daily_count = 1
    end
    
    self.save
  end
  
end

# == Schema Information
#
# Table name: tags
#
#  id           :integer(4)      not null, primary key
#  name         :string(64)      not null
#  daily_count  :integer(4)      default(0)
#  last_post_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

