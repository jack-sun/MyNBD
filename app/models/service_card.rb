#encoding:utf-8
class ServiceCard < ActiveRecord::Base
  belongs_to :service, :polymorphic => :true  
  belongs_to :staff
  has_one :payment
  STATUS_UNACTIVATED  = 0
  STATUS_ACTIVATED = 1

  TIME_1_MOUNTH = 0
  TIME_3_MOUNTH = 1
  TIME_6_MOUNTH = 2
  TIME_12_MOUNTH = 3
  TIME_TYPE = {TIME_1_MOUNTH => 1, TIME_3_MOUNTH => 3, TIME_6_MOUNTH => 6, TIME_12_MOUNTH => 12}
  STATUS_TYPE = {STATUS_ACTIVATED => "已使用", STATUS_UNACTIVATED => "未使用"}

  def overdue?
    return false if self.status == STATUS_UNACTIVATED
    self.activated_at + TIME_TYPE[self.card_type].months < Time.now
  end

  def time_length_str
    "#{TIME_TYPE[self.card_type]}个月"
  end

  def status_str
    return "已过期" if self.overdue? 
    return STATUS_TYPE[self.status]
  end

  def ServiceCard.init_temp_new_card(count)
    card_nos = ServiceCard.select(:card_no).map(&:card_no)
    accounts = []
    time = Time.now.strftime("%Y%m%d")
    count.times do
      number = "#{time}#{ServiceCard.random_number(100000000)}"
      password = ServiceCard.random_number(10000000000000000)
      while card_nos.include?(number) do
        number = "#{time}#{ServiceCard.random_number(100000000)}"
      end
      accounts << [number, password]
      card_nos << number
    end
    return accounts
  end

  def self.init_new_card(type, plan_type)
    temp = ServiceCard.new(:card_type => type, :plan_type => plan_type)
    temp.card_no = init_random_number(:card_no)
    temp.password = init_random_number(:password)
    temp.save!
    temp
  end

  def status_valid?
    self.status == STATUS_UNACTIVATED
  end

  def self.password_valid?(password)
    card = ServiceCard.where(:password => password).first && card.valid?
  end

  def self.card_no_valid?(card_no)
    card = ServiceCard.where(:card_no => card_no).first && card.valid?
  end

  private
  def self.init_random_number(type)
    count = 1
    number = SecureRandom.random_number(10000000000000000)
    while count != 0
      count = ServiceCard.where(type => number).count
      number = SecureRandom.random_number(10000000000000000)
    end
    return number.to_s
  end

  def self.random_number(number)
    result = SecureRandom.random_number(number)
    puts result
    puts number / 10
    while result < (number / 10) do
      result = SecureRandom.random_number(number)
    puts result
    end
    result
  end
end
