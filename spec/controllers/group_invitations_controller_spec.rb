require 'spec_helper'

describe GroupInvitationsController do
  
  describe "GET new" do
    
    before { set_current_user_session }
    
    context "with authenticated user" do
      
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
      
      it "assigns @invitation" do
        get :new, id: group.id
        
        expect(assigns(:invitation)).to be_new_record
        expect(assigns(:invitation)).to be_instance_of(GroupInvitation)
      end
    end
    
    context "with unauthenticated user" do
      
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :new, id: group.id }
      end
    end
  end
  
end