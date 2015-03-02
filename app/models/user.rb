class User < ActiveRecord::Base
  has_many :requests, -> { order start: :asc }
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}
  validates :full_name, presence: true
  
  has_secure_password validations: false
  
  def friend_requests
    Request.where.not(user_id: self).order('start ASC')
  end
  
end