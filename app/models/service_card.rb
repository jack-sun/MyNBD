#encoding:utf-8
class ServiceCard < ActiveRecord::Base
  belongs_to :service, :polymorphic => :true  
  belongs_to :staff
  has_one :payment
  belongs_to :card_sub_task, :class_name => "CardSubTask", :foreign_key => "task_id"
  belongs_to :create_staff, :class_name => "Staff", :foreign_key => :staff_id
  belongs_to :reviewed_staff, :class_name => "Staff", :foreign_key => :review_staff_id

  STATUS_UNREVIEW = -1
  STATUS_UNACTIVATED  = 0
  STATUS_ACTIVATED = 1

  TIME_1_MOUNTH = 0
  TIME_3_MOUNTH = 1
  TIME_6_MOUNTH = 2
  TIME_12_MOUNTH = 3

  TIME_TYPE = {TIME_1_MOUNTH => 1, TIME_3_MOUNTH => 3, TIME_6_MOUNTH => 6, TIME_12_MOUNTH => 12}

  CARD_TYPE_TTYJ = 0
  CARD_TYPE_GMS = 1

  CARD_TYPES = {CARD_TYPE_TTYJ => '天天赢家', CARD_TYPE_GMS => '股东大会实录'}

  STATUS_TYPE = {STATUS_ACTIVATED => "已使用", STATUS_UNACTIVATED => "未使用"}

  PASSWORD_PREFIX = 'nbd'

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

  def self.init_temp_new_card(count)
    #TODO: performace issue
    exist_cards = ServiceCard.select([:card_no, :password]) 
    cards_infos = {}
    exist_cards.each{|card| cards_infos.merge!({card.card_no => card.password})}

    # card_nos = exist_cards.map(&:card_no)
    # card_passwords = exist_cards.map(&:password)

    accounts = []
    time = Time.now.strftime("%Y%m%d")
    count.times do
      number = self.generate_random_str(time, 8) #card number always take time stamp as prefix
      password = self.generate_random_str(PASSWORD_PREFIX, 13) #card password always take 'nbd' as prefix
      
      while cards_infos.has_key?(number) do
        number = self.generate_random_str(time, 8)
      end

      while cards_infos.has_value?(password) do
        password = self.generate_random_str(PASSWORD_PREFIX, 13)
      end

      accounts << [number, password]
      cards_infos.merge!({number => password})
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

  def self.generate_card_number_and_password
    exist_cards = ServiceCard.select([:card_no, :password]) 
    cards_infos = {}
    exist_cards.each{|card| cards_infos.merge!({card.card_no => card.password})}

    time = Time.now.strftime("%Y%m%d")
    number = generate_random_str(time, 8) #card number always take time stamp as prefix
    password = generate_random_str(PASSWORD_PREFIX, 13) #card password always take 'nbd' as prefix
    while cards_infos.has_key?(number) do
      number = generate_random_str(time, 8)
    end
    while cards_infos.has_value?(password) do
      password = generate_random_str(PASSWORD_PREFIX, 13)
    end
    return number, password
  end

  def converted_card_type
    CARD_TYPES[card_type]
  end

  def converted_plan_type
    if card_type == CARD_TYPE_TTYJ
      time_length_str
    elsif card_type == CARD_TYPE_GMS
      GmsAccount::PLAN_TYPE[plan_type]
    end
  end

  private

  def self.generate_random_str(prefix, size)
    prefix + ServiceCard.random_number("1#{'0'*size}".to_i).to_s
  end

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
