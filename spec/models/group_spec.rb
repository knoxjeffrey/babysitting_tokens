require 'spec_helper'

describe Group do
  
  it { should have_many :user_groups}
  it { should have_many(:users).through(:user_groups) }
  it { should have_many :request_groups}
  it { should have_many(:requests).through(:request_groups) }
  
  it { should belong_to :admin }
  
  it { should validate_presence_of :group_name }
  it { should validate_presence_of :location }
  
  it { should validate_uniqueness_of :group_name }
  
  it { should validate_length_of(:group_name).is_at_least(3) } 
  
  describe :friends_in_group do
    
    let!(:current_user) { object_generator(:user) }
    let!(:friend_user1) { object_generator(:user) }
    let!(:friend_user2) { object_generator(:user) }
    let!(:group) { object_generator(:group) }
    let!(:group_member1) { object_generator(:user_group, user: current_user, group: group) }
    let!(:group_member2) { object_generator(:user_group, user: friend_user1, group: group) }
    let!(:group_member3) { object_generator(:user_group, user: friend_user2, group: group) }
    
    it "returns a list of friends in the current users group" do
      expect(group.friends_in_group(current_user)).to eq([friend_user1, friend_user2])
    end

  end
  
end
  