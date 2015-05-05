require "spec_helper"

describe JoinGroupRequestHandler do
  
  describe :handle_join_group_request do
    
    context "when user has requested to join" do
      let!(:requester) { object_generator(:user) }
      let!(:group_member) { object_generator(:user) }
      let!(:group) { object_generator(:group) }
      let!(:user_group) { object_generator(:user_group, user: group_member, group: group) }
      let!(:join_group_request) { object_generator(:join_group_request, requester: requester, group_member: group_member, group: group) }
      let!(:options) { join_group_request.id }
    
      it "expires the identifier" do
        JoinGroupRequestHandler.new(options).handle_join_group_request
        expect(JoinGroupRequest.first.identifier).to be nil
      end
      
      it "adds the requesting user to the group the invitation came from" do
        JoinGroupRequestHandler.new(options).handle_join_group_request
        expect(UserGroup.count).to eq(2)
      end
    end
  end
end