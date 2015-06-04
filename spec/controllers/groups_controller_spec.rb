require 'spec_helper'

describe GroupsController do
  
  describe "GET index" do
    
    before { set_current_user_session }
    
    context "with authenticated user" do
      let!(:group1) { object_generator(:group, admin: current_user) }
      let!(:group_member1) { object_generator(:user_group, user: current_user, group: group1) }
      let!(:group2) { object_generator(:group, admin: current_user) }
      let!(:group_member2) { object_generator(:user_group, user: current_user, group: group2) }
      
      it "assigns @groups" do
        get :index
        expect(assigns(:groups)).to match_array([group1, group2])
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
      it "assigns @group" do
        set_current_user_session
        get :new
        expect(assigns(:group)).to be_new_record
        expect(assigns(:group)).to be_instance_of(Group)
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
          post :create, group: generate_attributes_for(:group)
        end
    
        it "creates a new request" do
          expect(Group.count).to eq(1)
        end
        
        it "creates a new group associated with the user" do
          expect(Group.first.admin).to eq(current_user)
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
          post :create, group: generate_attributes_for(:group, circle_name: "Edinburgh", location: "")
        end
        
        it "does not create a new request" do
          expect(Group.count).to eq(0)
        end
        
        it "renders the new template" do
          expect(response).to render_template :new
        end
        
        it "sets @group" do
          expect(assigns(:group)).to be_new_record
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