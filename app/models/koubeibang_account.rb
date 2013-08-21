#encoding:utf-8
require 'spreadsheet'
require 'concerns/encrypt_password'

class KoubeibangAccount < ActiveRecord::Base

  include EncryptPassword
  
  set_table_name "kbb_accounts"

  has_many :koubeibang_votes, :foreign_key => "kbb_account_id"

  MAIL_UNSEND = 0
  MAIL_SENDED = 1

  attr_accessible :name, :hashed_password, :salt, :declaration,  
                  :real_name, :phone_no, :email, :inviter, :company_name, :sended_mail

  validates_presence_of :name, :hashed_password, :salt,
                        :real_name, :phone_no, :email, :inviter,
                        :declaration, :on => :update

  validates_length_of :real_name, :inviter,
                      :maximum => 32, :on => :update

  validates :phone_no, :length => { :minimum => 7, :maximum => 32 }, 
                       :format => { :with => /(^\d{3,4}-|^)(\d{7,8}|\d{11})$/ }, 
                       :on => :update

  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, 
                    :length => { :maximum => 64 }, 
                    :on => :update

  validates :declaration, :length => { :maximum => 1000 }

  before_create do |koubeibangAccount|
    koubeibangAccount.salt = generate_salt
    koubeibangAccount.name = NBD::Utils.to_md5("#{object_id}#{salt}")[0...6]
    koubeibangAccount.generate_rand_password(:name, 8)
  end

  def voted?
    self.koubeibang_votes.present?
  end

  def sended_email!
    self.update_attributes!(:sended_mail => MAIL_SENDED)
  end

  def export_vote_result
      Spreadsheet.client_encoding = 'UTF-8'
      file = Spreadsheet.open("#{Rails.root}/public/hzd_basic.xls")
      sheet = file.worksheets.first
      fill_basic_info(sheet)
      koubeibangs = Koubeibang.all
      row_index = 14
      koubeibangs.each_with_index do |koubeibang, koubeibang_index|
        row_index = 14 + (12 * koubeibang_index)
        sheet.row(row_index)[0] = "#{koubeibang.title}"
        koubeibang_candidate_ids = koubeibang.koubeibang_candidates.map(&:id)
        koubeibangVotes = koubeibang_votes.where(:kbb_candidate_id => koubeibang_candidate_ids)
        koubeibangVotes.each_with_index do |koubeibangVote, index|
          candidate = koubeibangVote.koubeibang_candidate
          sheet.row(row_index + index + 1)[0] = "#{candidate.stock_code}--#{candidate.stock_company}"
        end
      end
      path = "#{Rails.root}/tmp/#{company_name}_结果_回执单.xls"
      file.write path
      path
    end

    def export_basic_info
      Spreadsheet.client_encoding = 'UTF-8'
      file = Spreadsheet.open("#{Rails.root}/public/hzd_basic.xls")
      sheet = file.worksheets.first
      fill_basic_info(sheet)
      path = "#{Rails.root}/tmp/#{company_name}_回执单.xls"
      file.write path
      path
    end

    def fill_basic_info(sheet)
      sheet.each_with_index do |row, row_index|
        current = sheet.row(row_index)[0]
        current ||= ""
        content = case row_index
        when 3
          company_name
        when 4
          real_name
        when 5
          phone_no
        when 6
          email
        when 7
          inviter
        when 8
          created_at.strftime("%Y-%m-%d %H:%M")
        end
        sheet.row(row_index)[0] = "#{current}#{content}"
      end
      # file.write "#{Rails.root}/tmp/#{company_name}_回执单.xls"
    end

end
