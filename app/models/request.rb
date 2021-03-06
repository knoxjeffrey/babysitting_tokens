class Request < ActiveRecord::Base
  include TokensCalculated
  
  belongs_to :user
  belongs_to :group
  
  has_many :request_groups, dependent: :destroy
  has_many :groups, through: :request_groups
  has_many :declined_requests
  
  validates :start, presence: true
  validates :finish, presence: true
  validate :finish_is_after_start
  
  validates :request_groups, presence: true
  
  delegate :full_name, to: :user
  
  # Returns an array of future requests that a given user is babysitting for that have status of accepted
  def self.babysitting_info(user)
    where(["babysitter_id = ? and status = ? and start > ?", user.id, 'accepted', DateTime.now]).sort_by { |request| request[:start] }
  end
  
  def change_status_to_accepted
    self.update_attribute(:status, 'accepted')
  end
  
  def change_status_to_expired
    self.update_attribute(:status, 'expired')
  end
  
  def change_status_to_completed
    self.update_attribute(:status, 'completed')
  end
  
  # Sets the babysitter_id to the id of the user that accepted the request
  def update_babysitter(current_user)
    self.update_attribute(:babysitter_id, current_user.id)
  end
  
  # Returns the name of the person that accepted the babysitting request
  def babysitter_name
    User.find(self.babysitter_id).full_name if self.babysitter_id
  end
  
  # Sets the group_id of the group the request was accepted from
  def update_babysitter_group(group)
    self.update_attribute(:group_id, group.id)
  end
  
  # Returns the name of the group the babysitting request was accepted from
  def group_for_babysitting_date
    self.group.group_name
  end
  
  # Sets the babysitting_id and groups_id back to nil and changes the status back to waiting when an accepted
  # babysitting date is canceled. This allows the request to go back on the list for requests for babysitting
  def cancel_babysitting_agreement
    self.update_columns(status: 'waiting', babysitter_id: nil, group_id: nil)
  end
  
  # Returns an array of group ids for the groups that a request was not accepted from
  def groups_original_request_not_accepted_from
    self.group_ids.reject { |group_id| group_id == self.group_id }
  end
  
  # Returns an array of request groups that a request was made to
  def groups_request_was_made_to
    RequestGroup.where(request: self)
  end
  
  def group_request_was_accepted_by
    RequestGroup.find_by(request: self, group: self.group)
  end
  
  # Returns a positve or negative number of tokens depending if new request is longer, shorter or same as original request
  def calculate_token_difference_between_original_and_old_request(old_request)
    tokens_for_request(old_request) - tokens_for_request(self)
  end
  
  def calculate_tokens_for_request
    tokens_for_request(self)
  end
  
  def email_request_to_group_members(array_of_group_ids)
    array_of_group_ids.each do |group_id|
      user_group_records = UserGroup.where(group_id: group_id)
      user_group_email_and_name_array_of_hashes = user_group_records.map { |user_group| { email: user_group.user.email, name: user_group.user.full_name } }
      MyMailer.delay.notify_users_of_request(user_group_email_and_name_array_of_hashes, self)
    end
  end
  
  # A request is made out to a chosen list of groups. The list of friends in these groups that have not declined is returned
  def friends_not_declined(current_user)
    friends_in_group = []
    
    self.groups.each do |group|
      friends_in_group << group.friends_in_group(current_user)
    end
    friends_in_group.flatten!.uniq! 
    
    friends_in_group - self.friends_declined
  end
  
  # A request is made out to a chosen list of groups. The list of friends in these groups that have declined is returned
  def friends_declined
    friends_already_declined = []
    
    self.declined_requests.each do |decision|
      friends_already_declined << decision.user
    end
    friends_already_declined.uniq! 
    friends_already_declined
  end
  
  private
  
  def finish_is_after_start
    errors.add(:finish, "cannot be before the start date") if !start.blank? && !finish.blank? && finish < start
  end

end