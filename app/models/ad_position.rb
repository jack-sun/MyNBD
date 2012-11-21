class AdPosition < ActiveRecord::Base
  has_many :ads
  belongs_to :current_ad, :class_name => "Ad"

  def value_for_select
    "#{self.desc}  #{self.name.capitalize}"
  end
end
