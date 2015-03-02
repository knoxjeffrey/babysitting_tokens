class Request < ActiveRecord::Base
  belongs_to :user
  
  validates :start, presence: true
  validates :finish, presence: true
  
end