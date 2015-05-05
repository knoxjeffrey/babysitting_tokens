class User < ActiveRecord::Base
  include TokensCalculated
  
  has_many :requests, -> { order start: :asc }
  has_many :user_groups
  has_many :groups, -> { order group_name: :asc }, through: :user_groups
  has_many :authentications
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 5}
  validates :full_name, presence: true
  
  has_secure_password validations: false
  
  # returns all the users requests with a status of waiting or accepted
  # Also acts as a database tidy up by changing any status of waiting with a start date that has now passed
  # to a status of expired and will add the tokens back to the user groups
  # Also changes any accepted status with a start date that has now passed to a status of completed
  def waiting_and_accepted_requests
    requests = self.requests.where(status: ['waiting', 'accepted'])
    if requests.where(["start < ?", DateTime.now])
      handle_waiting_requests_with_past_start_date(requests)
      handle_accepted_requests_with_past_start_date(requests)
      return self.requests.where(status: ['waiting', 'accepted'])
    end
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
  
  # Subtracts tokens from a selected list of groups a user is a member of
  # The subtracted tokens depends on the length of the request
  def subtract_tokens(array_of_group_ids, request)
    array_of_group_ids.each do |group_id|
      tokens_requested = tokens_for_request(request)
      user_group_record = UserGroup.find_by(user: self, group_id: group_id)
      updated_tokens = user_group_record.tokens - tokens_for_request(request)
      user_group_record.update_tokens(updated_tokens)
    end
  end
  
  def add_tokens(request_group)
    user_group = UserGroup.find_by(user: self, group_id: request_group.group)
    updated_tokens = user_group.tokens + tokens_for_request(request_group.request)
    user_group.update_tokens(updated_tokens)
  end
  
  def reallocate_tokens(group, tokens)
    user_group = UserGroup.find_by(user: self, group_id: group)
    updated_tokens = user_group.tokens + tokens
    user_group.update_tokens(updated_tokens)
  end
  
  def generate_token
    self.update_column(:password_token, SecureRandom.urlsafe_base64)
  end
  
  def remove_password_token!
    self.update_column(:password_token, nil)
  end
  
  # An invited user or requesting user will be added as a member of the group specified
  def join_group(group)
    UserGroup.create(user: self, group: group) unless self.already_member_of_user_group(group)
  end
  
  # A user cannot join a user group they are already a member of
  def already_member_of_user_group(group)
    self.user_groups.exists?(group: group)
  end
  
  # Called on the class to search for a specific user full name
  # Can find partial matches and is case insensitive due to ILIKE. Returns an array of matches or empty array if no matches
  # Order is by full name
  # example User.search_by_title("je")
  # => ["Jeff Knox", "Jenny Lord"]
  def self.search_by_friend_full_name(friend_full_name)
    friend_full_name.present? ? where("full_name ILIKE ?", "%#{friend_full_name}%").order(full_name: :asc) : []
  end
    
  private
  
  # Changes any status of waiting with a start date that has now passed
  # to a status of expired and will add the tokens back to the user groups
  def handle_waiting_requests_with_past_start_date(requests)
    expired_requests = requests.where(["status = ? and start < ?", 'waiting', DateTime.now])
    expired_requests.each do |request| 
      request.change_status_to_expired
      request.request_groups.each { |request_group| self.add_tokens(request_group) }
    end
  end 
  # Changes any accepted status with a start date that has now passed to a status of completed
  def handle_accepted_requests_with_past_start_date(requests)
    old_accepted_requests = requests.where(["status = ? and start < ?", 'accepted', DateTime.now])
    old_accepted_requests.each { |request| request.change_status_to_completed }
  end
  
  # Returns an array of all request_groups from the groups the user is in, including the user
  def all_request_groups_from_current_users_groups
    group_ids = self.group_ids
    request_groups = group_ids.map { |id| RequestGroup.where(["group_id = ?", id]) }.flatten
  end
  
  # Removes any request_groups in the groups the user is a member of that were made by the user
  # Returns friend requests with a status of waiting that have a date in the future
  def only_friend_request_groups(all_request_groups_from_current_users_groups)
    friends_with_request_groups = all_request_groups_from_current_users_groups.reject { |request_group| request_group.request.user == self}
    request_groups = friends_with_request_groups.select { |request_group| request_group.request.status == 'waiting' && request_group.request.start >= DateTime.now }
    request_groups.sort_by { |request_group| request_group.request[:start] }
  end
  
end