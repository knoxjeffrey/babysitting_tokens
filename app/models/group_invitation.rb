class GroupInvitation < ActiveRecord::Base
  
  before_create :generate_identifier
  
  belongs_to :inviter, foreign_key: 'inviter_id', class_name: 'User'
  belongs_to :group
  
  validates :friend_email, presence: true, uniqueness: { scope: :group_id }
  validates_presence_of :friend_name, :message
  
  def clear_identifier_column
    self.update_column(:identifier, nil)
  end
  
  private
  
  def generate_identifier
    self.identifier = SecureRandom.urlsafe_base64
  end
  
end