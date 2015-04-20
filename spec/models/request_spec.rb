require 'spec_helper'

describe Request do
  it { should belong_to :user}
  it { should belong_to :group}
  
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
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id, status: 'accepted')

      expect(Request.babysitting_info(current_user)).to eq([request1])
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
  
  describe :change_status_to_expired do
    it "changes the status of the request to accepted" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      request1.change_status_to_expired
      expect(request1.status).to eq('expired')
    end
  end
  
  describe :change_status_to_completed do
    it "changes the status of the request to accepted" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      request1.change_status_to_completed
      expect(request1.status).to eq('completed')
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
  
  describe :babysitter_name do
    it "returns the full name of the babysitter" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      expect(request1.babysitter_name).to eq(current_user.full_name)
    end
  end
  
  describe :update_babysitter_group do
    it "sets the id of the person doing the babysitting" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member1 = object_generator(:user_group, user: current_user, group: group) 
      group_member2 = object_generator(:user_group, user: friend_user, group: group) 
      request1 = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id)
      
      request1.update_babysitter_group(group)
      expect(request1.group_id).to eq(group.id)
    end
  end
  
  describe :group_for_babysitting_date do
    it "returns the name of the group the request was accepted by" do
      current_user = object_generator(:user)
      friend_user = object_generator(:user)
      group = object_generator(:group)
      group_member = object_generator(:user_group, user: current_user, group: group) 
      group_member = object_generator(:user_group, user: friend_user, group: group) 
      request = object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id, group: group )
      
      expect(request.group).to eq(group)
    end
  end
  
  describe :cancel_babysitting_agreement do
    let!(:current_user) { object_generator(:user) }
    let!(:friend_user) { object_generator(:user) }
    let!(:group) { object_generator(:group) }
    let!(:group_member) { object_generator(:user_group, user: current_user, group: group) }
    let!(:group_member) { object_generator(:user_group, user: friend_user, group: group) }
    let!(:request) { object_generator(:request, user: friend_user, babysitter_id: current_user.id, group_ids: group.id, group: group, status: 'accepted' ) }
    
    it "sets the babysitter_id to nil" do
      request.cancel_babysitting_agreement
      expect(request.babysitter_id).to be nil
    end
    
    it "sets the group_id to nil" do
      request.cancel_babysitting_agreement
      expect(request.group_id).to be nil
    end
    
    it "sets the status to waiting" do
      request.cancel_babysitting_agreement
      expect(request.status).to eq('waiting')
    end
  end
  
end
