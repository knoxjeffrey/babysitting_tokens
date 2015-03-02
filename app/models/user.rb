class User < ActiveRecord::Base
  has_many :requests, -> { order start: :asc }
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}
  validates :full_name, presence: true
  
  has_secure_password validations: false
  
  def requests_except_complete
    self.requests.where.not(status: 'complete')
  end
  
  def friend_requests
    requests = Request.where(status: 'waiting')
    requests.where.not(user_id: self).order('start ASC')
  end
  
end