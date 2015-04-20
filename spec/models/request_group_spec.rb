require 'spec_helper'

describe RequestGroup do
  
  it { should belong_to :request }
  it { should belong_to :group }
  
  describe :tokens_for_babysitter do
    it "returns the number of tokens available for a babysitting request" do
      user = object_generator(:user)
      group = object_generator(:group)
      request = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: user, group_ids: group.id)
      
      expect(RequestGroup.first.tokens_for_babysitter).to eq(3)
    end
  end
  
end