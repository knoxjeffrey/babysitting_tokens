class Request < ActiveRecord::Base
  belongs_to :user
  
  validates :start, presence: true
  validates :finish, presence: true
  
  def self.babysitting_info(user)
    where(["babysitter_id = ?", user.id]).first
  end
  
end