class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  has_many :request_groups
  has_many :groups, through: :request_groups
  
  validates :start, presence: true
  validates :finish, presence: true
  validates :request_groups, presence: true
  
  delegate :full_name, to: :user
  
  def self.babysitting_info(user)
    where(["babysitter_id = ? and status = ?", user.id, 'accepted']).sort_by { |request| request[:start] }
  end
  
  def change_status_to_accepted
    self.update_attribute(:status, 'accepted')
  end
  
  def update_babysitter(current_user)
    self.update_attribute(:babysitter_id, current_user.id)
  end
  
  def babysitter_name
    User.find(self.babysitter_id).full_name if self.babysitter_id
  end
  
  def update_babysitter_group(group)
    self.update_attribute(:group_id, group.id)
  end
  
  def group_for_babysitting_date
    self.group.group_name
  end
  
end