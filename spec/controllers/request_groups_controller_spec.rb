require 'spec_helper'

describe RequestGroupsController do
  
  describe "GET show" do
    
    context "with authenticated user" do
      it "assigns @request_group" do
        set_current_user_session
        group = object_generator(:group, admin: current_user)
        request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user, group_ids: group.id)
        get :show, id: RequestGroup.first.id
        expect(assigns(:request_group)).to eq(RequestGroup.first)
      end
    end
    
    context "with unauthenticated user" do
      it "redirects to root path" do
        signed_out_user = object_generator(:user)
        group = object_generator(:group, admin: signed_out_user)
        request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, group_ids: group.id)
        get :show, id: RequestGroup.first.id
        
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe "PUT update" do
    
    context "with authenticated user" do
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group1) { object_generator(:group, admin: friend_user) }
      let!(:group_member1) { object_generator(:user_group, user: friend_user, group: group1) }
      
      context "when the request has been made to one group" do

        let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, group_ids: group1.id) }
      
        before do 
          set_current_user_session
          group_member2 = object_generator(:user_group, user: current_user, group: group1)

          put :update, id: RequestGroup.first.id
        end
      
        it "changes the status from waiting to accepted" do
          expect(request.reload.status).to eq('accepted')
        end
      
        it "generates a successful flash message" do
          expect(flash[:success]).to be_present
        end
      
        it "redirects to home_page" do
          expect(response).to redirect_to home_path
        end
      
        it "adds tokens to current user for the correct group" do
          expect(UserGroup.second.tokens).to eq(23)
        end
      
        it "adds the current user to babysitter_id column" do
          expect(request.reload.babysitter_id).to eq(current_user.id)
        end
      
        it "does not credit the friend user account" do
          expect(UserGroup.first.tokens).to eq(20)
        end
        
      end
      
      context "when the request has been made to more than one group" do
        
        let!(:group2) { object_generator(:group, admin: friend_user) }
        let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group2) }
        let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, group_ids: [group1.id, group2.id]) }
      
        before do 
          set_current_user_session
          group_member3 = object_generator(:user_group, user: current_user, group: group1)
          group_member4 = object_generator(:user_group, user: current_user, group: group2)
          
          put :update, id: RequestGroup.first.id
        end
      
        it "changes the status from waiting to accepted" do
          expect(request.reload.status).to eq('accepted')
        end
      
        it "generates a successful flash message" do
          expect(flash[:success]).to be_present
        end
      
        it "redirects to home_page" do
          expect(response).to redirect_to home_path
        end
      
        it "adds tokens to current user for the correct group" do
          expect(UserGroup.third.tokens).to eq(23)
        end
      
        it "adds the current user to babysitter_id column" do
          expect(request.reload.babysitter_id).to eq(current_user.id)
        end
      
        it "credits the friend for the group the babysitting request wasn't accepted from" do
          expect(UserGroup.second.tokens).to eq(23)
        end
        
      end
    
    end
    
    context "with unauthenticated user" do
      let(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: friend_user) }
      let!(:group_member) { object_generator(:user_group, user: friend_user, group: group) }
      let(:request1) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, group_ids: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { put :update, id: request1 }
      end
    end
    
  end
  
end
    