require 'spec_helper'

describe RequestsController do
  
  describe "GET index" do
    
    context "with authenticated user" do
      
      before { set_current_user_session }
      
      let!(:request1) { object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user) }
      let!(:request2) { object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: current_user) }
      
      it "assigns @user_requests" do
        get :index
        expect(assigns(:user_requests)).to match_array([request1, request2])
      end
      
      it "sorts @user_requests in ascending order by date" do
        get :index
        expect(assigns(:user_requests)).to eq([request2, request1])
      end
      
      it "only shows @user_requests with status waiting or accepted" do
        request3 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user, status: 'complete')
        get :index
        
        expect(assigns(:user_requests)).to eq([request2, request1])
      end
      
      it "assigns @friend_requests" do
        friend_user = object_generator(:user)
        request3 = object_generator(:request, user: friend_user)
        get :index
        
        expect(assigns(:friend_requests)).to eq([request3])
      end
      
      it "sorts @freind_requests in ascending order by date" do 
        friend_user = object_generator(:user)
        request3 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user)
        request4 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: friend_user)
        get :index
        
        expect(assigns(:friend_requests)).to eq([request4, request3])
      end  
      
      it "only shows @friend_requests with status waiting" do
        friend_user = object_generator(:user)
        request3 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user, status: 'accepted')
        request4 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: friend_user)
        get :index
        
        expect(assigns(:friend_requests)).to eq([request4])
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
        before do   
          post :create, request: generate_attributes_for(:request, start: 3.days.from_now, finish: 4.days.from_now)
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
        
      end
      
      context "with invalid user input" do

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
      it "assigns @show_request" do
        set_current_user_session
        request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user)
        get :show, id: request1
        expect(assigns(:request)).to eq(request1)
      end
    end
    
    context "with unauthenticated user" do
      it "redirects to root path" do
        request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now)
        get :show, id: request1
        
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe "POST update" do
    
    context "with authenticated user" do
      it "changes the status from waiting to accepted" do
        set_current_user_session
        friend_user = object_generator(:user)
        request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user)
      end
      
      it "redirects to home_page"
    end
    
    context "with unauthenticated user" do
      
    end
    
  end
  
end
