require 'spec_helper'

describe UserGroupsController do
  
  describe "POST create" do
    
    let(:requester) { object_generator(:user) }
    let(:group) { object_generator(:group) }
    let(:join_group_request) { object_generator(:join_group_request, requester: requester, group: group) }
    
    context "with authenticated user" do
      
      before do
        set_current_user_session
        post :create, request_id: join_group_request.id
      end
      
      it "redirects to the home page" do
        expect(response).to redirect_to home_path
      end
      
      it "generates a successful flash message" do
        expect(flash[:success]).to be_present
      end
      
      it "creates a new user group" do
        expect(UserGroup.count).to eq (1)
      end
      
      it "clears the identifier" do
        expect(join_group_request.reload.identifier).to be nil
      end
      
    end
    
    context "with unauthenticated user" do
      
      it_behaves_like "require_sign_in" do
        let(:action) { post :create, request_id: join_group_request.id }
      end
    end
    
  end
  
end