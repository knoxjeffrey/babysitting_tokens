require 'spec_helper'

describe AuthenticationsController do
  
  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
  end
    
  describe "POST create" do
    
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
    end
    
    context "with no existing user account" do
        
      context "signing in from the sign in page with facebook" do
        
        it "redirects to register_path" do
          #get :create, provider: :facebook
          #expect(response).to redirect_to register_path
        end
        
      end
      
      context "registering with facebook" do
        
      end
      
    end
    
  end
  
end