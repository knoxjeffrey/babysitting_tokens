require 'spec_helper'

describe Request do
  it { should belong_to :user}
  
  it { should validate_presence_of :start }
  it { should validate_presence_of :finish }
  
  it "has a default status value of waiting" do
    new_request = object_generator(:request)
    
    expect(new_request.status).to eq('waiting')
  end
  
  describe :babysitting_info do
    it "returns an array of dates where the current user is the babysitter" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id)
      
      expect(Request.babysitting_info(current_user)). to eq(request1)
    end
  end
  
end
