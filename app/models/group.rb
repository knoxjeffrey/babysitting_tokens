class Group < ActiveRecord::Base
  
  has_many :user_groups
  has_many :users, through: :user_groups
  
  has_many :request_groups
  has_many :requests, through: :request_groups
  
  belongs_to :admin, foreign_key: 'user_id', class_name: 'User'
  
  validates :group_name, presence: true, uniqueness: true, length: {minimum: 3}
  validates :location, presence: true
end