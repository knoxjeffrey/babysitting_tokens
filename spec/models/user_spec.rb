require 'spec_helper'

describe User do
  
  it { should have_many :requests }
  
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_presence_of :full_name }
  
  it { should validate_uniqueness_of :email }
  
  it { should validate_length_of(:password).is_at_least(5) } 
  
  it "has a default of 20 tokens" do
    user1 = object_generator(:user)
    expect(user1.tokens).to eq(20)
  end
  
  describe :requests_except_complete do
    it "returns all current user requests without a status of complete" do
      user1 = object_generator(:user)
      request1 = object_generator(:request, user: user1, status: 'complete')
      request2 = object_generator(:request, user: user1)
      
      expect(user1.requests_except_complete).to eq([request2])
    end
  end
  
  describe :friend_requests do
    it "returns all requests by friends of the current user with a status of waiting" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      request1 = object_generator(:request, user: current_user)
      request2 = object_generator(:request, user: friend_user)
      request3 = object_generator(:request, user: friend_user, status: 'accepted')
      
      expect(current_user.friend_requests).to eq([request2])
    end
  end
  
  describe :has_insufficient_tokens? do
    it "returns true if user does not have enough tokens for request" do 
      current_user = object_generator(:user)
      current_user.tokens = 0
      request1 = object_generator(:request, start: 3.days.from_now, finish: 4.days.from_now, user: current_user)
      
      expect(current_user.has_insufficient_tokens?(request1)).to be true
    end
  end
  
  describe :add_tokens do
    it "adds tokens to the current user" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      request1 = object_generator(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", user: friend_user)
      current_user.add_tokens(request1)
      
      expect(current_user.tokens).to eq(23)
    end
  end
  
end