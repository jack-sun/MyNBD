require 'active_support/concern'

module EncryptPassword

  extend ActiveSupport::Concern

  included do
    attr_reader   :password
  end

  module ClassMethods
    def encrypt_password(password, salt)
      NBD::Utils.to_md5(password + "nbd-system-2.0" + salt)
    end
  end

  def password=(password)
    @password = password
    
    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  def generate_rand_password(attribute, length = 6)
    self.password= NBD::Utils.to_md5("#{self[attribute.to_s]}#{Time.now.to_i}")[0...length]
  end


  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  private
end