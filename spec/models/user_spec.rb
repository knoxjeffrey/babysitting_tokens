require 'spec_helper'

describe User do
  
  it { should have_many :requests }
  
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_presence_of :full_name }
  
  it { should validate_uniqueness_of :email }
  
  it { should validate_length_of(:password).is_at_least(5) } 
  
  describe :requests_except_complete do
    it "returns all current user requests without a status of complete" do
      user = object_generator(:user)
      group = object_generator(:group)
      group_member = object_generator(:user_group, user: user, group: group) 
      request1 = object_generator(:request, user: user, status: 'complete', group_ids: group.id)
      request2 = object_generator(:request, user: user, group_ids: group.id)
      
      expect(user.requests_except_complete).to eq([request2])
    end
  end
  
  describe :friend_requests do
    
    let!(:current_user) { object_generator(:user) }
    let!(:friend_user) { object_generator(:user) }
    let!(:group1) { object_generator(:group) }
    let!(:group_member1) { object_generator(:user_group, user: current_user, group: group1) }
    let!(:group_member2) { object_generator(:user_group, user: friend_user, group: group1) }
    
    it "returns all requests by friends of the current user that have a status of waiting" do
      request1 = object_generator(:request, user: current_user, group_ids: group1.id)
      request2 = object_generator(:request, user: friend_user, group_ids: group1.id)
      request3 = object_generator(:request, user: friend_user, status: 'accepted', group_ids: group1.id)
      
      expect(current_user.friend_requests).to eq([request2])
    end
    
    it "only returns requests made by people in same groups as current user" do
      stranger_user = object_generator(:user)
      group2 = object_generator(:group)
      group_member3 = object_generator(:user_group, user: stranger_user, group: group2)
      request1 = object_generator(:request, user: current_user, group_ids: group1.id)
      request2 = object_generator(:request, user: friend_user, group_ids: group1.id)
      request3 = object_generator(:request, user: stranger_user, group_ids: group2.id)
      expect(current_user.friend_requests).to eq([request2])
    end
    
    it "returns all requests by date ascending" do
      request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: friend_user, group_ids: group1.id)
      request2 = object_generator(:request, start: 2.days.from_now, finish: 3.days.from_now, user: friend_user, group_ids: group1.id)
      
      expect(current_user.friend_requests).to eq([request2, request1])
    end
    
    it "only returns requests for groups in which friend has enough tokens"
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
  
  describe :add_tokens do
    it "adds tokens to the current user" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member = object_generator(:user_group, user: current_user, group: group) 
      request1 = object_generator(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", user: friend_user, group_ids: group.id)
      current_user.add_tokens(request1)
      
      expect(current_user.user_groups.first.tokens).to eq(23)
    end
  end
  
end