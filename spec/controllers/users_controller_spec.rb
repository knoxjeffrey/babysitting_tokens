require 'spec_helper'

describe UsersController do
  
  describe "GET new" do
    it "assigns @user if not logged in" do
      get :new
      expect(assigns(:user)).to be_a_new_record
      expect(assigns(:user)).to be_instance_of(User)
    end
    
    it "redirects to home path if already logged in" do
      set_current_user_session
      get :new
      expect(response).to redirect_to home_path
    end
  end
  
  describe "POST create" do
    context "valid input details" do
      before { post :create, user: generate_attributes_for(:user) }
      
      it "creates user record" do
        expect(User.count).to eq(1)
      end
    
      it "redirects to sign_in path" do
        expect(response).to redirect_to sign_in_path
      end
    end
    
    context "invalid input details" do
      before { post :create, user: { email_address: 'junk' } }
      
      it "does not create user record" do
        expect(User.count).to eq(0)
      end
  
      it "renders the new template" do
        expect(response).to render_template :new
      end
  
      it "assigns @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end
    end
    
    context "invitations" do
      
      context "when user has been invited" do
        let(:inviter) { object_generator(:user) }
        let(:group_invitation) { object_generator(:group_invitation, inviter: inviter) }
      
        it "delegates to GroupInvitationHandler to handle invitation" do
          handled_group_invitation = double("handled_group_invitation")                         
          allow(GroupInvitationHandler).to receive(:new).and_return(handled_group_invitation)
          expect(handled_group_invitation).to receive(:handle_group_invitation)
          
          user_params = { email: group_invitation.friend_email, password: 'password', full_name: group_invitation.friend_name}
          post :create, user: user_params, group_invitation_identifier: group_invitation.identifier
        end
      end
      
      context "when user hasn't been invited" do
        let(:inviter) { object_generator(:user) }
        let(:group_invitation) { object_generator(:group_invitation, inviter: inviter) }
      
        it "does not delegate to GroupInvitationHandler to handle invitation" do
          handled_invitation = double("handled_invitation")                         
          allow(GroupInvitationHandler).to receive(:new).and_return(handled_invitation)
          expect(handled_invitation).not_to receive(:handle_invitation)
          
          post :create, user: generate_attributes_for(:user)
        end
      end
      
    end
    
    context "sending emails" do
      context "valid input details" do
        before do
          MandrillMailer.deliveries.clear 
          post :create, user: { email: 'knoxjeffrey@outlook.com', password: 'password', full_name: 'Jeff Knox' }
        end
        
        it "sends out the email" do
          expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq('knoxjeffrey@outlook.com')
        end
      
        it "sends email containing the users full name" do
          expect(MandrillMailer.deliveries.first.message["global_merge_vars"].first["content"]).to include("Jeff Knox")
        end
      end
      
      context "invalid input details" do
        before do
          MandrillMailer.deliveries.clear 
          post :create, user: { email: 'junk' }
        end
        
        it "does not send an email" do
          expect(MandrillMailer.deliveries.first).to be nil
        end
      end
    end
  end
  
  describe "GET show" do
    
    let(:user) { object_generator(:user) }
    
    context "with authenticated user" do
      it "assigns @user" do
        set_current_user_session
        get :show, id: user
        
        expect(assigns(:user)).to eq(user)
      end
    end
    
    context "with unauthenticated user" do
      it "redirects to expired identifier path" do
        get :show, id: user
        
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe "GET new_with_invitation_identifier" do
    
    context "with valid identifier" do
      
      context "with a non existing user" do
        
        let(:group_invitation) { object_generator(:group_invitation) }
        
        before { get :new_invitation_with_identifier, identifier: group_invitation.identifier }
      
        it "renders the :new view template" do
          expect(response).to render_template :new
        end
      
        it "assigns @user with friend email" do
          expect(assigns(:user).email).to eq(group_invitation.friend_email)
        end
      
        it "sets @group_invitation_identifier" do
          expect(assigns(:group_invitation_identifier)).to eq(group_invitation.identifier)
        end
        
      end
      
      context "with an existing user" do
        
        let!(:user) { object_generator(:user, email: 'knoxjeffrey@outlook.com') }
        let(:group_invitation) { object_generator(:group_invitation, friend_email: user.email) }
        
        it "redirects to home_path" do
          get :new_invitation_with_identifier, identifier: group_invitation.identifier
          
          expect(response).to redirect_to home_path
        end
        
        it "delegates to GroupInvitationHandler to handle invitation" do
          handled_group_invitation = double("handled_group_invitation")                         
          allow(GroupInvitationHandler).to receive(:new).and_return(handled_group_invitation)
          expect(handled_group_invitation).to receive(:handle_group_invitation)
          
          get :new_invitation_with_identifier, identifier: group_invitation.identifier
        end 
        
      end
      
    end
    
    context "with invalid identifier" do
      it "redirects to expired identifier path" do
        get :new_invitation_with_identifier, identifier: 'not valid'
        expect(response).to redirect_to expired_identifier_path
      end
    end
  end
  
  describe "POST search" do
    
    let!(:user) { object_generator(:user, email: 'knoxjeffrey@outlook.com', full_name: "Jeff Knox") }
    
    it "assigns @search_results for authenticated users" do
      set_current_user_session
      post :search, full_name: user.full_name
      expect(assigns(:search_results)).to eq([user])
    end
    
    it_behaves_like "require_sign_in" do
      let(:action) { post :search, full_name: user.full_name }
    end
  end
end