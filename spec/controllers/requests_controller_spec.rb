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
      
      context "for babysitting groups" do
        
        let!(:friend_user) { object_generator(:user) }
        let!(:group1) { object_generator(:group, admin: current_user) }
        let!(:group2) { object_generator(:group, admin: friend_user) }
        let!(:group_member1) { object_generator(:user_group, user: current_user, group: group1) }
        let!(:group_member2) { object_generator(:user_group, user: current_user, group: group2) }
        
        it "assigns @user_groups" do
          get :index
          expect(assigns(:user_groups)).to match_array([group_member1, group_member2])
        end
        
        it "only shows user_groups that the user is a member of" do
          group3 = object_generator(:group, admin: friend_user)
          group_member3 = object_generator(:user_group, user: friend_user, group: group3)
          
          get :index
          expect(assigns(:user_groups)).to match_array([group_member1, group_member2])
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
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
  
        before do   
          post :create, request: generate_attributes_for(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", group_ids: [group.id])
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
        
      end
      
      context "with user being a member of more than one group" do
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
        let!(:group2) { object_generator(:group, admin: current_user) }
        let!(:group_member2) { object_generator(:user_group, user: current_user, group: group2) }
        
        before do
          post :create, request: generate_attributes_for(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", group_ids: [group.id, group2.id])
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
        
      end
      
      
      context "with user having insufficient tokens" do
        
        let!(:group) { object_generator(:group, admin: current_user) }
        let!(:group_member) { object_generator(:user_group, user: current_user, group: group, tokens: 1) }
        
        context "when the user is only a member of one group" do
          
          before do
            post :create, request: generate_attributes_for(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", group_ids: [group.id])
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
        
        context "when the user is a member of more than one group and has insufficient tokens for at least one group request" do
          let!(:group2) { object_generator(:group, admin: current_user) }
          let!(:group_membe2) { object_generator(:user_group, user: current_user, group: group2, tokens: 50) }
          
          before do
            post :create, request: generate_attributes_for(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", group_ids: [group.id, group2.id])
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
  
end
