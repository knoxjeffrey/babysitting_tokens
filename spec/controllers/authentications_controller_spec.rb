require 'spec_helper'

describe AuthenticationsController do
    
  describe "POST create" do
    
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    end
    
    context "with user account already created" do
      
      let!(:user) { object_generator(:user, email: 'knoxjeffrey@outlook.com', full_name: 'Jeff Knox')}
      
      context "sigining in and already has facebook authentication" do
        
        let!(:authentication) {object_generator(:authentication, user_id: user.id)}
        
        it "redirects to home_path" do
          get :create, provider: :facebook
          expect(response).to redirect_to home_path
        end
        
        it "should set a session id" do
          get :create, provider: :facebook
          expect(session[:user_id]).not_to be nil
        end
      end
      
      context "already signed in and linking their facebook account" do
        
        context "when social email matches user email in User table" do
          
          before { session[:user_id] = user.id }
        
          it "redirects to home_path" do
            get :create, provider: :facebook
            expect(response).to redirect_to home_path
          end
        
          it "displays a success message" do
            get :create, provider: :facebook
            expect(flash[:success]).to be_present
          end
        
          it "creates a new authentication record" do
             get :create, provider: :facebook
             expect(Authentication.count).to eq(1)
          end
          
        end
        
        context "when social email does not match user email in User table" do
          
          let!(:other_user) { object_generator(:user, email: 'random@outlook.com', full_name: 'Some User')}
          
          before { session[:user_id] = other_user.id }
          
          it "redirects to home_path" do
            get :create, provider: :facebook
            expect(response).to redirect_to home_path
          end
        
          it "displays a danger message" do
            get :create, provider: :facebook
            expect(flash[:danger]).to be_present
          end
        
          it "creates a new authentication record" do
             get :create, provider: :facebook
             expect(Authentication.count).to eq(0)
          end
          
        end
        
      end
      
      context "signing in but with no facebook authentication" do
        
        it "redirects to home_path" do
          get :create, provider: :facebook
          expect(response).to redirect_to home_path
        end
        
        it "displays a success message" do
          get :create, provider: :facebook
          expect(flash[:success]).to be_present
        end
        
        it "creates a new authentication record" do
           get :create, provider: :facebook
           expect(Authentication.count).to eq(1)
        end
        
      end
    end
    
    context "with no existing user account" do
      
      context "signing in from the sign in page with facebook" do
        
        before { request.env['omniauth.params'] = { "from" => "" } }
        
        it "redirects to register_path" do
          get :create, provider: :facebook
          expect(response).to redirect_to register_path
        end
        
        it "displays a success message" do
          get :create, provider: :facebook
          expect(flash[:danger]).to be_present
        end
        
      end
      
      context "registering with facebook from the registration page" do
        
        context "when facebook account can be verified" do
          
<<<<<<< HEAD
          before do
=======
          before do 
>>>>>>> staging
            MandrillMailer.deliveries.clear 
            request.env['omniauth.params'] = { "from" => "registration" }
          end
        
          it "redirects to sign_in path" do
            get :create, provider: :facebook
            expect(response).to redirect_to sign_in_path
          end
        
          it "creates user record" do
            get :create, provider: :facebook
            expect(User.count).to eq(1)
          end
        
          it "sends out the email" do
            get :create, provider: :facebook
            expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq('knoxjeffrey@outlook.com')
          end
        
          it "sends email containing the users full name" do
            get :create, provider: :facebook
            expect(MandrillMailer.deliveries.first.message["global_merge_vars"].first["content"]).to include("Jeff Knox")
          end
        
          context "when user has been invited" do
          
            before { request.env['omniauth.params'] = { "from" => "registration", "invite" => '12345' } }
      
            it "delegates to GroupInvitationHandler to handle invitation" do
              handled_group_invitation = double("handled_group_invitation")                         
              allow(GroupInvitationHandler).to receive(:new).and_return(handled_group_invitation)
              expect(handled_group_invitation).to receive(:handle_group_invitation)
          
              get :create, provider: :facebook
            end
          end
        
          context "when user hasn't been invited" do
            let(:inviter) { object_generator(:user) }
            let(:group_invitation) { object_generator(:group_invitation, inviter: inviter) }
      
            it "does not delegate to GroupInvitationHandler to handle invitation" do
              handled_invitation = double("handled_invitation")                         
              allow(GroupInvitationHandler).to receive(:new).and_return(handled_invitation)
              expect(handled_invitation).not_to receive(:handle_invitation)
          
              get :create, provider: :facebook
            end
          end
          
        end
        
        context "when facebook account cannot be verified" do
          
          before { request.env['omniauth.params'] = { "from" => "registration" } }
          
          it "redirects to UsersController new action" do

          end
          
        end
        
      end
      
    end
    
  end
  
end