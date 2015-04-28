class GroupInvitationHandler
  
  def initialize(options={})
    @user = options[:user]
    @identifier = options[:group_invitation_identifier]
  end
  
  def handle_group_invitation
    group_invitation = GroupInvitation.find_by(identifier: identifier)
    group_invitation.clear_identifier_column
    user.join_inviters_group(group_invitation.group)
  end
  
  private
  
  attr_reader :identifier, :user
  
end