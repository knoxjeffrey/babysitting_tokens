require 'spec_helper'

describe JoinGroupRequestsController do
  
  describe "POST create" do
    
    context "with authenticated user" do
      
      before do
        MandrillMailer.deliveries.clear 
        set_current_user_session
      end
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: user) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      
      it "redirects to the invite friend page" do
        post :create, user_id: user.id, group_id: group.id
        expect(response).to redirect_to user_path(user.id)
      end
      
      it "creates a join group request" do
        post :create, user_id: user.id, group_id: group.id
        expect(JoinGroupRequest.count).to eq(1)
      end
      
      it "sends an email to the group member" do
        post :create, user_id: user.id, group_id: group.id
        expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq(user.email)
      end
      
      it "sends an email that has the requesters name" do
        post :create, user_id: user.id, group_id: group.id
        expect(MandrillMailer.deliveries.first.message["global_merge_vars"].first["content"]).to include(current_user.full_name)
      end
      
      it "sends an email that contains the group name" do
        post :create, user_id: user.id, group_id: group.id
        expect(MandrillMailer.deliveries.first.message["global_merge_vars"].second["content"]).to include(group.group_name)
      end
      
      it "generates a successful flash message" do
        post :create, user_id: user.id, group_id: group.id
        expect(flash[:success]).to be_present
      end

    end
    
    context "with unauthenticated user" do
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: user) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { post :create, id: user.id }
      end
    end
  end
  
  describe "GET show" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      let(:requester) { object_generator(:user) }
      let(:group) { object_generator(:group) }
      
      context "with valid identifier" do
        it "sets @request_to_join_group to the correct identifier record" do
          request = object_generator(:join_group_request, requester_id: requester.id, group_member_id: current_user.id, group_id: group.id)
          get :show, identifier: request.identifier
          expect(assigns(:request_to_join_group).identifier).to eq(request.identifier)
        end
      end
      
      context "with invalid identifier" do
        it "redirects to expired identifier path" do
          request = object_generator(:join_group_request, requester: requester, group_member: current_user, group: group)
          get :show, identifier: 'not valid'
          expect(response).to redirect_to expired_identifier_path
        end
      end
      
    end
    
    context "with unauthenticated user" do
      
      let(:requester) { object_generator(:user) }
      let(:group) { object_generator(:group) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :create, identifier: '1234567' }
      end
    end
  
  end
  
end