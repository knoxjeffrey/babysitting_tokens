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
  
  def has_insufficient_tokens?(request)
    if request.user.tokens < tokens_for_request(request)
      true
    else
      subtract_tokens(request)
      false
    end
  end
  
  def add_tokens(request)
    updated_tokens = self.tokens + tokens_for_request(request)
    self.update_attribute(:tokens, updated_tokens)
  end
  
  def tokens_for_request(request)
    ((request.finish - request.start) / 1.hour).round
  end
  
  def subtract_tokens(request)
    updated_tokens = self.tokens - tokens_for_request(request)
    self.update_attribute(:tokens, updated_tokens)
  end
  
end