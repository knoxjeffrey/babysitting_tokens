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
      
      expect(Request.babysitting_info(current_user)).to eq(request1)
    end
  end
  
  describe :change_status_to_accepted do
    it "changes the status of the request to accepted" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      request1.change_status_to_accepted
      expect(request1.status).to eq('accepted')
    end
  end
  
  describe :update_babysitter do
    it "sets the id of the person doing the babysitting" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      request1.update_babysitter(current_user)
      expect(request1.babysitter_id).to eq(current_user.id)
    end
  end
  
end
