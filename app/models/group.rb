class Group < ActiveRecord::Base
  
  belongs_to :user
  
  validates :group_name, presence: true, uniqueness: true, length: {minimum: 5}
  validates :location, presence: true
end