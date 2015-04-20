class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  has_many :request_groups, dependent: :destroy
  has_many :groups, through: :request_groups
  
  validates :start, presence: true
  validates :finish, presence: true
  validates :request_groups, presence: true
  
  delegate :full_name, to: :user
  
  # Returns an array of requests for a given user that have status of accepted
  def self.babysitting_info(user)
    where(["babysitter_id = ? and status = ?", user.id, 'accepted']).sort_by { |request| request[:start] }
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

end