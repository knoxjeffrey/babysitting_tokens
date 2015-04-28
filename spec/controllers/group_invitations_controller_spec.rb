require 'spec_helper'

describe GroupInvitationsController do
  
  describe "GET new" do
    
    before { set_current_user_session }
    
    context "with authenticated user" do
      
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
      
      it "assigns @group_invitation" do
        get :new, id: group.id
        
        expect(assigns(:group_invitation)).to be_new_record
        expect(assigns(:group_invitation)).to be_instance_of(GroupInvitation)
      end
    end
    
    context "with unauthenticated user" do
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: user) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :new, id: group.id }
      end
    end
  end
  
  describe "POST create" do
    
    context "with authenticated user" do
      
      before do
        MandrillMailer.deliveries.clear 
        set_current_user_session
      end
      
      context "with valid input" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
        
        before { post :create, id: group.id, group_invitation: generate_attributes_for(:group_invitation, friend_name: "Test Friend", friend_email: "test@test.com") }
        
        it "redirects to the invite friend page" do
          expect(response).to redirect_to group_path(group.id)
        end
        
        it "creates a group invitation" do
          expect(GroupInvitation.count).to eq(1)
        end
        
        it "sends an email to the invited friend" do
          expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq('test@test.com')
        end
        
        it "generates a successful flash message" do
          expect(flash[:success]).to be_present
        end
      end
      
      context "with invalid input" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
        
        before { post :create, id: group.id, group_invitation: generate_attributes_for(:group_invitation, friend_name: nil, friend_email: "test@test.com") }
        
        it "does not create a new invitation" do
          expect(GroupInvitation.count).to eq(0)
        end
        
        it "does not send out an invitation email" do
          expect(MandrillMailer.deliveries.first).to be nil
        end
  
        it "renders the new template" do
          expect(response).to render_template :new
        end
        
        it "assigns @group_invitation" do
          expect(assigns(:group_invitation)).to be_present
        end
      end
    end
    
    context "with unauthenticated user" do
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: user) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { post :create, id: group.id }
      end
    end
  end
  
end