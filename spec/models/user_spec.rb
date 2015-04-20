require 'spec_helper'

describe User do
  
  it { should have_many :requests }
  it { should have_many :user_groups}
  it { should have_many(:groups).through(:user_groups) }
  
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_presence_of :full_name }
  
  it { should validate_uniqueness_of :email }
  
  it { should validate_length_of(:password).is_at_least(5) } 
  
  describe :waiting_and_accepted_requests do
    it "returns all current user requests with a status of waiting or accepted" do
      user = object_generator(:user)
      group = object_generator(:group)
      group_member = object_generator(:user_group, user: user, group: group) 
      request1 = object_generator(:request, user: user, status: 'complete', group_ids: group.id)
      request2 = object_generator(:request, user: user, group_ids: group.id)
      
      expect(user.waiting_and_accepted_requests).to eq([request2])
    end
    
    context "with a status of waiting that is past the start date" do
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group) }
      let!(:group2) { object_generator(:group) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      let!(:group_member2) { object_generator(:user_group, user: user, group: group2) }
      let!(:request) { object_generator(:request, start: "2013-03-17 19:00:00", finish: "2013-03-17 22:00:00", user: user, group_ids: [group.id, group2.id]) }
      
      it "does not return the request" do
        expect(user.waiting_and_accepted_requests).to eq([])
      end
      
      it "changes the request status to expired" do
        user.waiting_and_accepted_requests
        expect(Request.first.status).to eq('expired')
      end
      
      it "adds the tokens for the request back to the usergroups it was made for" do
        user.waiting_and_accepted_requests
        tokens_array = user.user_groups.map { |group| group.tokens }
        expect(tokens_array.sum).to eq(46)
      end
      
    end
    
    context "with a status of accepted that is past the start date" do
      
      let!(:user) { object_generator(:user) }
      let!(:group) { object_generator(:group) }
      let!(:group_member) { object_generator(:user_group, user: user, group: group) }
      let!(:request) { object_generator(:request, start: "2013-03-17 19:00:00", finish: "2013-03-17 22:00:00", user: user, group_ids: group.id, status: 'accepted') }
      
      it "does not return the request" do
        expect(user.waiting_and_accepted_requests).to eq([])
      end
      
      it "changes the request status to expired" do
        user.waiting_and_accepted_requests
        expect(Request.first.status).to eq('completed')
      end
      
    end
  end
  
  describe :friend_request_groups do
    
    let!(:current_user) { object_generator(:user) }
    let!(:friend_user) { object_generator(:user) }
    let!(:group1) { object_generator(:group) }
    let!(:group_member1) { object_generator(:user_group, user: current_user, group: group1) }
    let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group1) }
    
    it "returns all requests by friends of the current user that have a status of waiting" do
      request1 = object_generator(:request, user: current_user, group_ids: group1.id)
      request2 = object_generator(:request, user: friend_user, group_ids: group1.id)
      request3 = object_generator(:request, user: friend_user, status: 'accepted', group_ids: group1.id)
      
      expect(current_user.friend_request_groups).to eq([RequestGroup.second])
    end
    
    it "only returns requests made by people in same groups as current user" do
      stranger_user = object_generator(:user)
      group2 = object_generator(:group)
      group_member3 = object_generator(:user_group, user: stranger_user, group: group2)
      request1 = object_generator(:request, user: current_user, group_ids: group1.id)
      request2 = object_generator(:request, user: friend_user, group_ids: group1.id)
      request3 = object_generator(:request, user: stranger_user, group_ids: group2.id)
      expect(current_user.friend_request_groups).to eq([RequestGroup.second])
    end
    
    it "returns all requests by date ascending" do
      request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user, group_ids: group1.id)
      request2 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: friend_user, group_ids: group1.id)
      
      expect(current_user.friend_request_groups).to eq([RequestGroup.second, RequestGroup.first])
    end
    
  end
  
  describe :has_insufficient_tokens? do
    let!(:current_user) { object_generator(:user) }
    let!(:group) { object_generator(:group, admin: current_user) } 
    let!(:group_member) { object_generator(:user_group, user: current_user, group: group, tokens: 0) }
    
    it "returns true if user does not have enough tokens for request" do 
      
      request = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user, group_ids: group.id)
      expect(current_user.has_insufficient_tokens?(current_user.group_ids, request)).to be true
    end
  end
  
  describe :subtract_tokens do
    
    let!(:current_user) { object_generator(:user) }
    let!(:group) { object_generator(:group) }
    let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
    
    context "when user belongs to one group" do
      
      it "removes tokens from the current user for that group" do
        request = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: group.id)
        current_user.subtract_tokens([group.id], request)
        
        expect(current_user.user_groups.first.tokens).to eq(17)
      end
      
    end
    
    context "when user belong to nore than one group" do
      
      it "removes tokens from the current user for all groups" do
        group2 = object_generator(:group)
        group_member2 = object_generator(:user_group, user: current_user, group: group2)
        request = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: current_user, group_ids: [group.id, group2.id])
        current_user.subtract_tokens([group.id, group2.id], request)
        
        tokens_array = current_user.user_groups.map { |group| group.tokens }
        expect(tokens_array.sum).to eq(34)
      end
    end
    
  end
  
  describe :add_tokens do
    it "adds tokens to the user" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member = object_generator(:user_group, user: current_user, group: group) 
      request1 = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, group_ids: group.id)
      current_user.add_tokens(RequestGroup.first)
      
      expect(current_user.user_groups.first.tokens).to eq(23)
    end
  end
  
end