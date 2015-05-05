require 'spec_helper'

describe JoinGroupRequest do
  
  it { should belong_to :requester }
  it { should belong_to :group_member }
  it { should belong_to :group }
  
  describe "verify that an identifier is created" do
    it "changes the value of the identifier" do
      join_group_request = object_generator(:join_group_request)
      expect(join_group_request.identifier).not_to be nil
    end
  end
  
  describe :clear_identifier_column do
    it "sets identifier column to nil" do
      join_group_request = object_generator(:join_group_request)
      join_group_request.clear_identifier_column
      expect(JoinGroupRequest.last.identifier).to eq(nil)
    end
  end
  
end