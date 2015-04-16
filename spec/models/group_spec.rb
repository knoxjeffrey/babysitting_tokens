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
  
end
  