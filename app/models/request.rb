class Request < ActiveRecord::Base
  belongs_to :user
  
  has_many :request_groups
  has_many :groups, through: :request_groups
  
  validates :start, presence: true
  validates :finish, presence: true
  validates :request_groups, presence: true
  
  delegate :full_name, to: :user
  
  def self.babysitting_info(user)
    where(["babysitter_id = ?", user.id]).first
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
  
end