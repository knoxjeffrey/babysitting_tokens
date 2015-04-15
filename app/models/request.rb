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
  
end