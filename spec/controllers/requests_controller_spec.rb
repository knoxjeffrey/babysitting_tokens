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
  
  
end
