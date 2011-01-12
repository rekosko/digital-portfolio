# == Schema Information
# Schema version: 20110108115736
#
# Table name: users
#
#  id          :integer         not null, primary key
#  nickname    :string(255)
#  name        :string(255)
#  surname     :string(255)
#  age         :integer
#  email       :string(255)
#  www         :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :nickname, :name, :surname, :age, :email, :www, :description, :password, :password_confirmation
  has_many :galleries, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :nickname, :presence => true,
            :length   => { :maximum => 16 }
  validates :email, :presence => true,
            :format   => { :with => email_regex },
            :uniqueness => { :case_sensitive => false }
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
          
  #def feed
  #  Gallery.where("user_id = ?", id)
  #end
  
  scope :admin, where(:admin => true)
  
  def feed
    Gallery.from_users_followed_by(self)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end  
    
end