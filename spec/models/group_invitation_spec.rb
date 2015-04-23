require 'spec_helper'

describe GroupInvitation do
  
  it { should belong_to :inviter }
  it { should belong_to :group }
  
  it { should validate_presence_of :friend_email }
  it { should validate_presence_of :friend_name }
  it { should validate_presence_of :message }
  
  it { should validate_uniqueness_of :friend_email }
  
  describe "verify that an identifier is created" do
    it "changes the value of the identifier" do
      group_invitation = object_generator(:group_invitation)
      expect(group_invitation.identifier).not_to be nil
    end
  end

end