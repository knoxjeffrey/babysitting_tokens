require 'spec_helper'

describe Request do
  it { should belong_to :user}
  
  it { should validate_presence_of :start }
  it { should validate_presence_of :finish }
  
  it "has a default status value of waiting" do
    current_user = object_generator(:user)
    group = object_generator(:group)
    group_member = object_generator(:user_group, user: current_user, group: group) 
    request = object_generator(:request, user: current_user, group_ids: group.id)
    
    expect(request.status).to eq('waiting')
  end
  
  describe :babysitting_info do
    it "returns an array of dates where the current user is the babysitter" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      expect(Request.babysitting_info(current_user)). to eq(request1)
    end
  end
  
end
