class JoinGroupRequest < ActiveRecord::Base
  include ClearIdentifier
  
  before_create :generate_identifier
  
  belongs_to :requester, foreign_key: 'requester_id', class_name: 'User'
  belongs_to :group_member, foreign_key: 'group_member_id', class_name: 'User'
  belongs_to :group
  
  private
  
  def generate_identifier
    self.identifier = SecureRandom.urlsafe_base64
  end
  
end