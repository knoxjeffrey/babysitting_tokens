require 'spec_helper'

describe RequestsController do
  
  describe "GET index" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      context "for users own requests" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
        let!(:request1) { object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user, group_ids: group.id) }
        let!(:request2) { object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: current_user, group_ids: group.id) }
      
        it "assigns @user_requests" do
          get :index
          expect(assigns(:user_requests)).to match_array([request1, request2])
        end
      
        it "sorts @user_requests in ascending order by date" do
          get :index
          expect(assigns(:user_requests)).to eq([request2, request1])
        end
      
        it "only shows @user_requests with status waiting or accepted" do
          request3 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user, status: 'complete', group_ids: group.id)
          get :index
        
          expect(assigns(:user_requests)).to eq([request2, request1])
        end
        
      end
      
      context "for users friend requests" do
        let!(:friend_user) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
        let!(:request1) { object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user, group_ids: group.id) }
        
        it "assigns @friend_request_groups" do
          get :index
  
          expect(assigns(:friend_request_groups)).to eq([RequestGroup.first])
        end
      
        it "sorts @friend_request_groups in ascending order by date" do 
          request2 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: friend_user, group_ids: group.id)
          get :index
        
          expect(assigns(:friend_request_groups)).to eq([RequestGroup.second, RequestGroup.first])
        end  
      
        it "only shows @friend_request_groups with status waiting" do
          request2 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user, status: 'accepted', group_ids: group.id)
          get :index
        
          expect(assigns(:friend_request_groups)).to eq([RequestGroup.first])
        end
      
        it "only shows @friend_request_groups for people in the users group" do
          stranger_user = object_generator(:user)
          group2 = object_generator(:group, admin: stranger_user) 
          group_member3 = object_generator(:user_group, user: stranger_user, group: group2)
          request2 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: stranger_user, group_ids: group2.id)
          get :index
          
          expect(assigns(:friend_request_groups)).to eq([RequestGroup.first])
        end
        
      end
      
      context "for next date current user is babysitting" do
        
        let!(:friend_user) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
        
        context "if user has not accepted any request" do
          
          let!(:request1) { object_generator(:request, user: friend_user, status: 'waiting', group_ids: group.id) }
          let!(:request2) { object_generator(:request, user: friend_user, babysitter_id: current_user.id, status: 'complete', group_ids: group.id, group_id: group.id) }
          
          it "does not return any information" do
            get :index
            expect(assigns(:next_babysitting_info)).to be nil
          end
          
        end
        
        context "if user has accepted requests" do
          
          let!(:request1) { object_generator(:request, start: 3.days.from_now, finish: 3.days.from_now, user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: group.id, group_id: group.id) }
          let!(:request2) { object_generator(:request, start: 2.days.from_now, finish: 2.days.from_now, user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: group.id, group_id: group.id) }
          
          it "returns the next date the current user is babysitting" do
            get :index
            expect(assigns(:next_babysitting_info)).to eq(request2)
          end
          
        end
        
      end
      
    end
  
    context "with unauthenticated user" do
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :index }
      end
      
    end
  end
  
  describe "GET new" do
    
    context "with authenticated user" do
      it "assigns @request" do
        set_current_user_session
        get :new
        expect(assigns(:request)).to be_new_record
        expect(assigns(:request)).to be_instance_of(Request)
      end
    end
    
    context "with unauthenticated user" do
      it_behaves_like "require_sign_in" do
        let(:action) { get :new }
      end
    end
  end
  
  describe "POST create" do
    
    context "with authenticated user" do
      before { set_current_user_session }
      
      context "with valid user input" do
        
        let!(:friend) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend, group: group) }
  
        before do  
          MandrillMailer.deliveries.clear  
          post :create, request: generate_attributes_for(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", group_ids: [group.id])
        end
    
        it "creates a new request" do
          expect(Request.count).to eq(1)
        end
        
        it "creates a new request associated with the user" do
          expect(Request.first.user).to eq(current_user)
        end
        
        it "generates a successful flash message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the user home page" do
          expect(response).to redirect_to home_path
        end
        
        it "removes tokens from current user" do
          expect(current_user.user_groups.first.tokens).to eq(17)
        end
        
        it "sends an email to all users in the group" do
          expect(MandrillMailer.deliveries.first.message["to"].count).to eq(2)
        end
        
      end
      
      context "with user being a member of more than one group" do
        let!(:friend1) { object_generator(:user) }
        let!(:friend2) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend1, group: group) }
        let!(:group2) { object_generator(:group, admin: current_user) }
        let!(:group_member3) { object_generator(:user_group, user: current_user, group: group2) }
        let!(:group_member4) { object_generator(:user_group, user: friend1, group: group2) }
        let!(:group_member5) { object_generator(:user_group, user: friend2, group: group2) }
        
        before do
          MandrillMailer.deliveries.clear  
          post :create, request: generate_attributes_for(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", group_ids: [group.id, group2.id])
        end
        
        it "creates one request" do
          expect(Request.count).to eq(1)
        end
        
        it "creates a new request associated with the user" do
          expect(Request.first.user).to eq(current_user)
        end
        
        it "creates multiple user group entries" do
          expect(RequestGroup.count).to eq(2)
        end
        
        it "generates a successful flash message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the user home page" do
          expect(response).to redirect_to home_path
        end
        
        it "removes tokens from each group for current user" do
          tokens_array = current_user.user_groups.map { |group| group.tokens }
          expect(tokens_array.sum).to eq(34)
        end
        
        it "sends an email to all users of each of the groups selected" do
          all_emails = MandrillMailer.deliveries.map { |mail| mail.message["to"] }
          expect(all_emails.flatten.count).to eq(5)
        end
        
      end
      
      
      context "with user having insufficient tokens" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group, tokens: 1) }
        
        context "when the user is only a member of one group" do
          
          before do
            MandrillMailer.deliveries.clear 
            post :create, request: generate_attributes_for(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", group_ids: [group.id])
          end
          
          it "does not create a new request" do
            expect(Request.count).to eq(0)
          end
          
          it "generates a warning flash.now message" do
            expect(flash[:danger]).to be_present
          end
        
          it "renders new template" do
            expect(response).to render_template :new
          end
        
          it "sets @request" do
            expect(assigns(:request)).to be_new_record
          end
          
          it "does not send out any emails" do
            expect(MandrillMailer.deliveries).to eq([])
          end
          
        end
        
        context "when the user is a member of more than one group and has insufficient tokens for at least one group request" do
          let!(:group2) { object_generator(:group, admin: current_user) }
          let!(:group_membe2) { object_generator(:user_group, user: current_user, group: group2, tokens: 50) }
          
          before do
            post :create, request: generate_attributes_for(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", group_ids: [group.id, group2.id])
          end
          
          it "does not create a new request" do
            expect(Request.count).to eq(0)
          end
          
          it "generates a warning flash.now message" do
            expect(flash[:danger]).to be_present
          end
        
          it "renders new template" do
            expect(response).to render_template :new
          end
        
          it "sets @request" do
            expect(assigns(:request)).to be_new_record
          end
        end
        
      end
          
      context "with invalid user input" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
        
        before do 
          post :create, request: generate_attributes_for(:request, start: 3.days.from_now, finish: nil)
        end
        
        it "does not create a new request" do
          expect(Request.count).to eq(0)
        end
        
        it "renders the my_request_path" do
          expect(response).to render_template('requests/new')
        end
        
        it "sets @request" do
          expect(assigns(:request)).to be_new_record
        end
       
      end
      
    end
    
    context "with unauthenticated user" do
      it_behaves_like "require_sign_in" do
        let(:action) { post :create }
      end
    end
    
  end
  
  describe "GET show" do
    
    context "with authenticated user" do
      
      context "that created the request" do
        
        before { set_current_user_session }
      
        let!(:friend_user) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
        let!(:request) { object_generator(:request, user: current_user, group_ids: group.id) }
      
        it "only shows the requests the current user is babysitting for" do
          get :show, id: request.id
          expect(assigns(:request)).to eq(request)
          expect(assigns(:request)).to be_instance_of(Request)
        end
        
      end
        
      context "that did not create the request" do
        
        before { set_current_user_session }
      
        let!(:friend_user) { object_generator(:user) }
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
        let!(:request) { object_generator(:request, user: friend_user, group_ids: group.id) }
        
        it "redirects to home_path" do
          get :show, id: request.id
          expect(request).to redirect_to home_path
        end
        
        it "generates a danger flash message" do
          get :show, id: request.id
          expect(flash[:danger]).to be_present
        end
      end

    end
    
    context "with unauthenticated user" do
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: friend_user) }
      let!(:group_member) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, user: friend_user, group_ids: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :show, id: request.id }
      end
    end
  end
  
  describe "GET edit" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
      let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, user: current_user, group_ids: group.id) }
      
      it "only shows the requests the current user is babysitting for" do
        get :edit, id: request.id
        expect(assigns(:request)).to eq(request)
        expect(assigns(:request)).to be_instance_of(Request)
      end

    end
    
    context "with unauthenticated user" do
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: friend_user) }
      let!(:group_member) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, user: friend_user, group_ids: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :edit, id: request.id }
      end
    end
    
  end
  
  describe "PUT update" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      context "with request having status of waiting" do
      
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group2) { object_generator(:group, admin: current_user) }
        let!(:group3) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group_member2) { object_generator(:user_group, user: current_user, group: group2) }
        let!(:group_member3) { object_generator(:user_group, user: current_user, group: group3) }
        let!(:request) { object_generator(:request, start: "2030-03-17 17:00:00", finish: "2030-03-17 20:00:00", user: current_user, group_ids: group.id) }
      
        context "with changes" do
          
          context "with date and group changes" do
          
            context "it alters the dates and groups in the database" do
              before do
                put :update, id: request.id, request: { start: "2030-03-17 18:00:00", finish: "2030-03-17 23:00:00", user: current_user, group_ids: [group2.id, group3.id] }
                request.reload
              end  
            
        
              it "redirects back to the home page do" do
                expect(response).to redirect_to home_path
              end
        
              it "changes the start date of the request" do
                expect(request.start).to eq("2030-03-17 18:00:00")
              end
        
              it "changes the finish date of the request" do
                expect(request.finish).to eq("2030-03-17 23:00:00")
              end
        
              it "deletes any unchecked boxes from RequestGroup table" do
                request_groups = RequestGroup.all.map { |request_group| request_group.group_id }
                expect(request_groups).not_to include(group.id)
              end
        
              it "adds any checked boxes to UserGroup table" do
                request_groups = RequestGroup.all.map { |request_group| request_group.group_id }
                expect(request_groups).to eq([group2.id, group3.id])
              end
            end
            
            # This checks token allocation when the selected groups are totally different to the original request
            # If I was looking at the case when the same group was selected then I'd have to check the cases when
            # the new request was longer, shorter or the same as the original request. I check the same group cases
            # in the next test
            context "it changes the token allocation when groups chosen are totally different to original request" do
              
              before do
                put :update, id: request.id, request: { start: "2030-03-17 18:00:00", finish: "2030-03-17 23:00:00", user: current_user, group_ids: [group2.id, group3.id] }
                request.reload
              end  
              
              it "adds tokens based on original request back to user if they deselect group" do
                expect(UserGroup.first.tokens).to eq(23)
              end
              
              it "deducts tokens based on new request from the current_user for all newly selected groups" do
                expect(UserGroup.second.tokens).to eq(15)
                expect(UserGroup.third.tokens).to eq(15)
              end

            end
            
            context "it changes the token allocation when groups chosen are added to the groups of the original request" do
              
              before do
                put :update, id: request.id, request: { start: "2030-03-17 18:00:00", finish: "2030-03-17 23:00:00", user: current_user, group_ids: [group.id, group2.id, group3.id] }
                request.reload
              end 
              
              it "makes a change to the tokens for the group that has stayed the same based on difference between old and new request" do
                expect(UserGroup.first.tokens).to eq(18)
              end
              
              it "deducts tokens based on new request from the current_user for all newly selected groups" do
                expect(UserGroup.second.tokens).to eq(15)
                expect(UserGroup.third.tokens).to eq(15)
              end
            end
            
          end
          
          context "with date change but no group change" do
            
            context "with the altered request being for more hours than the original" do
              
              before do
                put :update, id: request.id, request: { start: "2030-03-17 15:00:00", finish: "2030-03-17 23:00:00", user: current_user, group_ids: [group.id] }
                request.reload
              end 
              
              it "deducts more tokens from that current users group" do
                expect(UserGroup.first.tokens).to eq(15)
              end
              
            end
            
            context "with the altered request being for less hours than the original" do
              
              before do
                put :update, id: request.id, request: { start: "2030-03-17 18:00:00", finish: "2030-03-17 19:00:00", user: current_user, group_ids: [group.id] }
                request.reload
              end 
              
              it "adds more tokens to that current users group" do
                expect(UserGroup.first.tokens).to eq(22)
              end
              
            end
            
            context "with the altered request being for the same duration as the original" do
              
              before do
                put :update, id: request.id, request: { start: "2030-03-17 17:00:00", finish: "2030-03-17 20:00:00", user: current_user, group_ids: [group.id] }
                request.reload
              end 
              
              it "makes no token change to that current users group" do
                expect(UserGroup.first.tokens).to eq(20)
              end
              
            end
              
          end
           
        end

        context "with no changes" do
        
          before do
            put :update, id: request.id, request: { start: "2030-03-17 17:00:00", finish: "2030-03-17 20:00:00", user: current_user, group_ids: [group.id] }
            request.reload
          end
        
          it "redirects back to the home page do" do
            expect(response).to redirect_to home_path
          end
        
          it "keeps the start date of the request" do
            expect(request.start).to eq("2030-03-17 17:00:00")
          end
        
          it "keeps the finish date of the request" do
            expect(request.finish).to eq("2030-03-17 20:00:00")
          end
        
          it "keeps the same entry in RequestGroup table" do
            request_groups = RequestGroup.all.map { |request_group| request_group.group_id }
            expect(request_groups).to include(group.id)
          end
        
        end
      
        context "with invalid user input" do
        
          before do
            put :update, id: request.id, request: { start: "2030-03-17 18:00:00", finish: "", user: current_user, group_ids: [group2.id, group3.id] }
            request.reload
          end
        
          it "keeps the start date of the original request" do
            expect(request.start).to eq("2030-03-17 17:00:00")
          end
        
          it "keeps the finish date of the original request" do
            expect(request.finish).to eq("2030-03-17 20:00:00")
          end
        
          it "renders the update template" do
            expect(response).to render_template :edit
          end
          
          it "keeps the groups of the original request" do
            expect(RequestGroup.count).to eq(1)
          end
        
        end
      
        context "with user having insufficient tokens" do
        
          before do
            put :update, id: request.id, request: { start: "2030-03-17 19:00:00", finish: "2030-03-27 22:00:00", user: current_user, group_ids: [group.id] }
            request.reload
          end
        
          it "keeps the start date of the original request" do
            expect(request.start).to eq("2030-03-17 17:00:00")
          end
        
          it "keeps the finish date of the original request" do
            expect(request.finish).to eq("2030-03-17 20:00:00")
          end
        
          it "renders the update template" do
            expect(response).to render_template :edit
          end
        
          it "generates a warning flash.now message" do
            expect(flash[:danger]).to be_present
          end
        
        end
      end
      
      context "with request not having status of waiting" do

        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
        let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: group.id, status: "accepted") }
      
        before do
          put :update, id: request.id, request: { start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: [group.id], status: "accepted" }
          request.reload
        end
      
        it "redirects to home path" do
          expect(response).to redirect_to home_path
        end
      
        it "generates a warning flash.now message" do
          expect(flash[:danger]).to be_present
        end
      end
      
    end
    
    context "with unauthenticated user" do
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: friend_user) }
      let!(:group_member) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, user: friend_user, group_ids: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :update, id: request.id }
      end
      
    end
  end
  
  describe "GET destroy" do
    
    before { set_current_user_session }
    
    let!(:friend_user) { object_generator(:user) }
    let!(:group) { object_generator(:group, admin: current_user) }
    let!(:group2) { object_generator(:group, admin: current_user) }
    let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
    let!(:group_member2) { object_generator(:user_group, user: current_user, group: group2) }
    let!(:group_member3) { object_generator(:user_group, user: friend_user, group: group) }
    let!(:group_member4) { object_generator(:user_group, user: friend_user, group: group2) }
  
    context "with authenticated user" do
      
      context "when the request had not been accepted yet" do
        
        context "when the request was made to one group" do
          
          let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: group.id) }
        
          before do
            get :destroy, id: request.id
          end
        
          it "deletes the request" do
            expect(Request.count).to eq(0)
          end
      
          it "deletes all associated records in RequestGroup table" do
            expect(RequestGroup.count).to eq(0)
          end
        
          it "adds the tokens back to the user group the current user made the request to" do
            expect(UserGroup.first.tokens).to eq(23)
          end
          
          it "does not alter the user group the current user did not make the request to" do
            expect(UserGroup.second.tokens).to eq(20)
          end
          
        end
        
        context "when the request was made to more than one group" do
          
          let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: [group.id, group2.id]) }
        
          before do
            get :destroy, id: request.id
          end
        
          it "deletes the request" do
            expect(Request.count).to eq(0)
          end
      
          it "deletes all associated records in RequestGroup table" do
            expect(RequestGroup.count).to eq(0)
          end
        
          it "adds the tokens back to all the user groups the current user made the request to" do
            expect(UserGroup.first.tokens).to eq(23)
            expect(UserGroup.second.tokens).to eq(23)
          end
          
        end
        
      end
      
      
      context "when the request had been accepted" do
        
        let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, status: 'accepted', group_ids: [group.id, group2.id], group_id: group.id, babysitter_id: friend_user.id) }
        
        before do
          get :destroy, id: request.id
        end
      
        it "deletes the request" do
          expect(Request.count).to eq(0)
        end
      
        it "deletes all associated records in RequestGroup table" do
          expect(RequestGroup.count).to eq(0)
        end
      
        it "adds tokens back to current user for their group that the request had been accepted from" do
          expect(UserGroup.first.tokens).to eq(23)
        end
      
        it "does not alter the token amount for the current user group from which the request had not been accepted from" do
          expect(UserGroup.second.tokens).to eq(20)
        end
      
        it "deducts the tokens from the users group that accepted the request" do
          expect(UserGroup.third.tokens).to eq(17)
        end
      
        it "does not alter the token amount for the user group from which the user had not accepted the request from" do
          expect(UserGroup.fourth.tokens).to eq(20)
        end
        
      end
      
    end
    
    context "with unauthenticated user" do
      
      let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { get :destroy, id: request.id }
      end
    end

  end
  
  describe "GET index_babysitting_dates" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
      let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request1) { object_generator(:request, user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: group.id, group_id: group.id) }
      let!(:request2) { object_generator(:request, user: friend_user, babysitter_id: current_user.id, status: 'complete', group_ids: group.id, group_id: group.id) }
      
      it "only shows the requests the current user is babysitting for" do
        get :my_babysitting_dates
        expect(assigns(:current_user_babysitting_for_requests)).to eq([request1])
      end

    end
    
    context "with unauthenticated user" do
      it_behaves_like "require_sign_in" do
        let(:action) { get :my_babysitting_dates }
      end
    end
  end
  
  describe "PUT cancel_babysitting_date" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      let!(:friend_user) { object_generator(:user, email: "knoxjeffrey@outlook.com") }
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
      let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: group.id, group_id: group.id) }
      
      it "clears the babysitter_id" do
        put :cancel_babysitting_date, id: request.id
        expect(request.reload.babysitter_id).to be nil
      end
      
      it "clears the group_id" do
        put :cancel_babysitting_date, id: request.id
        expect(request.reload.group_id).to be nil
      end
      
      it "changes the status to waiting" do
        put :cancel_babysitting_date, id: request.id
        expect(request.reload.status).to eq('waiting')
      end
      
      it "removes the tokens from the babysitter that were originally allocated when the request was accepted" do
        put :cancel_babysitting_date, id: request.id
        expect(current_user.user_groups.first.tokens).to eq(17)
      end
      
      it "sends an email to the user that requested the date for a babysitter" do
        MandrillMailer.deliveries.clear 
        put :cancel_babysitting_date, id: request.id
        expect(MandrillMailer.deliveries.first.message["to"].first["email"]).to eq('knoxjeffrey@outlook.com')
      end
      
      context "if the original request was made to one group" do
        it "does not change the tokens for the user group the request was originally made from" do
          put :cancel_babysitting_date, id: request.id
          expect(friend_user.user_groups.first.tokens).to eq(20)
        end
      end
      
      context "if the original request was made to more than one group" do
        
        let!(:group2) { object_generator(:group, admin: current_user) }
        let!(:group_member3) { object_generator(:user_group, user: current_user, group: group2) }
        let!(:group_member4) { object_generator(:user_group, user: friend_user, group: group2) }
        let!(:request2) { object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: [group.id, group2.id], group_id: group.id) }
        
        it "does not change the tokens for the requester user group the request was originally made from" do
          put :cancel_babysitting_date, id: request2.id
          expect(friend_user.user_groups.first.tokens).to eq(20)
        end
        
        it "removes the tokens from the other requester user groups the request was originally made from" do
          put :cancel_babysitting_date, id: request2.id
          expect(friend_user.user_groups.second.tokens).to eq(17)
        end
      end
      
    end
    
    context "with unauthenticated user" do
      
      let!(:current_user) { object_generator(:user) }
      let!(:friend_user) { object_generator(:user) }
      let!(:group) { object_generator(:group, admin: current_user) }
      let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
      let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group) }
      let!(:request) { object_generator(:request, user: friend_user, babysitter_id: current_user.id, status: 'accepted', group_ids: group.id, group_id: group.id) }
      
      it_behaves_like "require_sign_in" do
        let(:action) { put :cancel_babysitting_date, id: request.id}
      end
    end
    
  end
  
end
