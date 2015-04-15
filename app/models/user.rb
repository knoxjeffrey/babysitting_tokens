class User < ActiveRecord::Base
  has_many :requests, -> { order start: :asc }
  has_many :user_groups
  has_many :groups, through: :user_groups
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}
  validates :full_name, presence: true
  
  has_secure_password validations: false
  
  def requests_except_complete
    self.requests.where.not(status: 'complete')
  end
  
  def friend_requests
    all_requests_from_current_users_groups
    only_friend_requests(all_requests_from_current_users_groups)
  end
  
  def has_insufficient_tokens?(selected_group_ids, request)
    insufficient_tokens = false
    selected_group_ids.each do |group_id|
      tokens_available = UserGroup.find_by(user: self, group_id: group_id).tokens
      insufficient_tokens = true if tokens_available < tokens_for_request(request)
    end
    insufficient_tokens
  end
  
  def subtract_tokens(current_user_groups_array, request)
    current_user_groups_array.each do |user_group|
      tokens_requested = tokens_for_request(request)
      user_group_record = UserGroup.find_by(user: self, group_id: user_group)
      updated_tokens = user_group_record.tokens - tokens_for_request(request)
      user_group_record.update_attributes(tokens: updated_tokens)
    end
  end
  
  def add_tokens(request)
    updated_tokens = self.user_groups.first.tokens + tokens_for_request(request)
    self.user_groups.first.update_attribute(:tokens, updated_tokens)
  end
    
  private
  
  def tokens_for_request(request)
    ((request.finish - request.start) / 1.hour).round
  end
  
  def all_requests_from_current_users_groups
    group_ids = self.group_ids
    request_groups = group_ids.map { |id| RequestGroup.where(["group_id = ?", id]) }.flatten
    request_groups.map { |request_group| request_group.request }
  end
  
  def only_friend_requests(all_requests)
    friends_with_requests = all_requests.reject { |requests| requests.user_id == self.id }
    friends_with_requests.select { |request| request.status == 'waiting' }.sort_by { |date| date[:start] }
  end
  
end