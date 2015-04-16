class User < ActiveRecord::Base
  include TokensCalculated
  
  has_many :requests, -> { order start: :asc }
  has_many :user_groups
  has_many :groups, through: :user_groups
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}
  validates :full_name, presence: true
  
  has_secure_password validations: false
  
  # returns all the users requests that aren't complete
  def requests_except_complete
    self.requests.where.not(status: 'complete')
  end
  
  # returns all requests by people in the same groups as the user that are waiting to be accepted
  def friend_request_groups
    all_request_groups_from_current_users_groups
    only_friend_request_groups( all_request_groups_from_current_users_groups)
  end
  
  # A user can make a request for babysitting to more than one of their groups
  # If they do not have tokens for one or more of the selected groups then
  # insufficient tokens is set to true.
  def has_insufficient_tokens?(selected_group_ids, request)
    insufficient_tokens = false
    selected_group_ids.each do |group_id|
      tokens_available = UserGroup.find_by(user: self, group_id: group_id).tokens
      insufficient_tokens = true if tokens_available < tokens_for_request(request)
    end
    insufficient_tokens
  end
  
  # When a user makes a request to one or more of their groups then tokens are
  # subracted from each of their groups
  def subtract_tokens(current_user_groups_array, request)
    current_user_groups_array.each do |user_group|
      tokens_requested = tokens_for_request(request)
      user_group_record = UserGroup.find_by(user: self, group_id: user_group)
      updated_tokens = user_group_record.tokens - tokens_for_request(request)
      user_group_record.update_attributes(tokens: updated_tokens)
    end
  end
  
  def add_tokens(request_group)
    user_group = UserGroup.find_by(user: self, group_id: request_group.group)
    updated_tokens = user_group.tokens + tokens_for_request(request_group.request)
    user_group.update_attribute(:tokens, updated_tokens)
  end
    
  private
  
  # Returns an array of all request_groups from the groups the user is in, including the user
  def all_request_groups_from_current_users_groups
    group_ids = self.group_ids
    request_groups = group_ids.map { |id| RequestGroup.where(["group_id = ?", id]) }.flatten
  end
  
  # Removes any request_groups in the groups the user is a member of that were made by the user
  def only_friend_request_groups(all_request_groups_from_current_users_groups)
    friends_with_request_groups = all_request_groups_from_current_users_groups.reject { |request_group| request_group.request.user == self}
    request_groups = friends_with_request_groups.select { |request_group| request_group.request.status == 'waiting' }.sort_by { |request_group| request_group.request[:start] }
    request_groups.sort_by { |request_group| request_group.request[:start] }
  end
  
end