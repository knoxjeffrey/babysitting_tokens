require 'spec_helper'

describe ForgotPasswordsController do
  
  describe "POST create" do
    context "with valid input" do
      
      let(:valid_user) { object_generator(:user, email: 'knoxjeffrey@outlook.com') }
      before do
        MandrillMailer.deliveries.clear
        post :create, email: valid_user.email
      end
      
      it "redirects to the forgot password confirmation page" do 
        expect(response).to redirect_to forgot_password_confirmation_path
      end
      
      it "sends an email to the email address" do
        expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq('knoxjeffrey@outlook.com')
      end
      
      it "generates a random token" do
        expect(valid_user.reload.password_token).to be_present
      end
      
      it "sends email containing a link to password_resets path with the random token" do
        expect(MandrillMailer.deliveries.first.message["global_merge_vars"].second["content"]).to include("#{password_resets_path}/#{valid_user.reload.password_token}")
      end
    end
    
    context "with invalid input" do
      
      context "with blank input" do
        
        before do
          MandrillMailer.deliveries.clear
          post :create, email: ''
        end
        
        it "redirects to forgot password page" do
          expect(response).to redirect_to forgot_password_path
        end
        
        it "shows an error message" do
          expect(flash[:danger]).to eq("Email cannot be blank. Please try again.")
        end
        
      end
      
      context "with email address not in database" do
        
        before do
          MandrillMailer.deliveries.clear
          post :create, email: 'knoxy@outlook.com'
        end
        
        it "redirects to forgot password page" do
          expect(response).to redirect_to forgot_password_path
        end
        
        it "shows an error message" do
          expect(flash[:danger]).to be_present
        end
        
      end
      
    end
    
  end
end