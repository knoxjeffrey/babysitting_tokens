class JoinGroupRequest < ActiveRecord::Base
  
  before_create :generate_identifier
  
  belongs_to :requester, foreign_key: 'requester_id', class_name: 'User'
  belongs_to :group_member, foreign_key: 'group_member_id', class_name: 'User'
  belongs_to :group
  
  def clear_identifier_column
    self.update_column(:identifier, nil)
  end
  
  private
  
  def generate_identifier
    self.identifier = SecureRandom.urlsafe_base64
  end
  
end