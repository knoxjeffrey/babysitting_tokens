require "spec_helper"

describe GroupInvitationHandler do
  
  describe :handle_group_invitation do
    
    context "when user has been invited" do
      let(:inviter) { object_generator(:user) }
      let(:group_invitation) { object_generator(:group_invitation, inviter: inviter) }
      let(:invited_user) { object_generator(:user, email: group_invitation.friend_email) }
      let(:options) { { user: invited_user, group_invitation_identifier: group_invitation.identifier } }
    
      it "expires the group invitation upon creation" do
        GroupInvitationHandler.new(options).handle_group_invitation
        expect(GroupInvitation.first.identifier).to be nil
      end
    end
  end
end