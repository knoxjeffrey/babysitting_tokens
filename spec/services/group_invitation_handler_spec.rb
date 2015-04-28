require "spec_helper"

describe GroupInvitationHandler do
  
  describe :handle_group_invitation do
    
    context "when user has been invited" do
      let!(:inviter) { object_generator(:user) }
      let!(:group) { object_generator(:group) }
      let!(:group_member) { object_generator(:user_group, user: inviter, group: group) }
      let!(:group_invitation) { object_generator(:group_invitation, inviter: inviter, group: group) }
      let!(:invited_user) { object_generator(:user, email: group_invitation.friend_email) }
      let!(:options) { { user: invited_user, group_invitation_identifier: group_invitation.identifier } }
    
      it "expires the group invitation upon creation" do
        GroupInvitationHandler.new(options).handle_group_invitation
        expect(GroupInvitation.first.identifier).to be nil
      end
      
      it "adds the invited user to the group the invitation came from" do
        GroupInvitationHandler.new(options).handle_group_invitation
        expect(UserGroup.count).to eq(2)
      end
    end
  end
end