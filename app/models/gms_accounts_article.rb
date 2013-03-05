#encoding:utf-8
class GmsAccountsArticle < ActiveRecord::Base
  belongs_to :gms_article
  belongs_to :gms_account
  belongs_to :user

  REFUND_CREDITS_STATUS = 0

  USER_STATUS_NO_ACCOUNT = -1
  USER_STATUS_NOT_PAID = 0
  USER_STATUS_RECEIVE_CREDITS = 1
  USER_STATUS_BOUGHT = 2
  USER_STATUS_UN_RECEIVE_CREDITS = 3
end
