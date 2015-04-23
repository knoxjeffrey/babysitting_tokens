class GroupInvitation < ActiveRecord::Base
  
  belongs_to :inviter, foreign_key: 'inviter_id', class_name: 'User'
  belongs_to :group
  
  validates :friend_email, presence: true, uniqueness: true
  validates_presence_of :friend_name, :message
  
end