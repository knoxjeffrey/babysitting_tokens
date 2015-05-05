class GroupInvitationHandler
  
  def initialize(options={})
    @user = options[:user]
    @identifier = options[:group_invitation_identifier]
  end
  
  # Clear the identifier in for the GroupInvitation record and join the user to group they were invited to
  def handle_group_invitation
    group_invitation = GroupInvitation.find_by(identifier: identifier)
    group_invitation.clear_identifier_column
    user.join_group(group_invitation.group)
  end
  
  private
  
  attr_reader :identifier, :user
  
end