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
  
  it "is invalid on update if password is less than 5 characters" do
    user = object_generator(:user)
    user.password = "tiny"
    user.save
    expect(user).not_to be_valid
  end
  
  it  "is valid on update if no password is passed" do
    user = object_generator(:user)
    user.email = "knoxy@outlook.com"
    user.save
    expect(user).to be_valid
  end
  
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
  
  describe :join_group do
    let!(:current_group_member) { object_generator(:user) }
    let!(:user_to_join) { object_generator(:user) }
    let!(:group) { object_generator(:group, admin: current_group_member) } 
    let!(:group_member) { object_generator(:user_group, user: current_group_member, group: group) }
    
    it "adds the user to the group specified" do
      user_to_join.join_group(group)
      
      expect(user_to_join.reload.user_groups.count).to eq(1)
    end
    
    it "does not add the user to a group if they are already a member of that group" do
      group_member = object_generator(:user_group, user: user_to_join, group: group)
      user_to_join.join_group(group)
      
      expect(user_to_join.reload.user_groups.count).to eq(1)
    end
    
  end
  
  describe :search_by_friend_full_name do
    let(:user1) { object_generator(:user, email: 'knoxjeffrey@outlook.com', full_name: "Jeff Knox") }
    let(:current_user) { object_generator(:user, full_name: "Jan Test") }
    
    it "should return an empty array if no title matches the search" do 
      expect(User.search_by_friend_full_name("Jeff Kerr", current_user)).to eq([])
    end
    
    it "should return an array of one title if there is a match" do
      expect(User.search_by_friend_full_name("Jeff Knox", current_user)).to eq([user1])
    end
    
    it "should return an array of one title that matches a partial search term" do
      expect(User.search_by_friend_full_name("eff", current_user)).to eq([user1])
    end
    
    it "should return an array of matches ordered by full_name" do
      user2 = object_generator(:user, email: 'jean@outlook.com', full_name: "Jean Lord")
      expect(User.search_by_friend_full_name("Je", current_user)).to eq([user2, user1])
    end
    
    it "should return an array of matches independent of case" do 
      user2 = object_generator(:user, email: 'jean@outlook.com', full_name: "Jean Lord")
      expect(User.search_by_friend_full_name("je", current_user)).to eq([user2, user1])
    end 
    
    it "should return an empty array for an empty string search term" do
      expect(User.search_by_friend_full_name("", current_user)).to eq([])
    end
    
    it "should not include the current user in the search results" do
      expect(User.search_by_friend_full_name("J", current_user)).to eq([user1])
    end
    
  end
  
end