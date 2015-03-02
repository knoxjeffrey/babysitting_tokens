require 'spec_helper'

describe User do
  
  it { should have_many :requests }
  
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_presence_of :full_name }
  
  it { should validate_uniqueness_of :email }
  
  it { should validate_length_of(:password).is_at_least(5) } 
  
  it "has a default status value of waiting" do
    user1 = object_generator(:user)
    new_request = object_generator(:request)
    
    expect(new_request.status).to eq('waiting')
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
  
end