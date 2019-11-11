class User < ApplicationRecord
  acts_as_token_authenticatable User
  has_one_attached :profile_photo
  has_many :subscriptions
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private
  def after_successful_token_authentication
  # Make the authentication token to be disposable - for example
  renew_authentication_token!
  end

  # Validate authentication token if exists
  def self.validate_token(id,auth_token)
    self.find_by_id(id).authentication_token == auth_token
  end
end
