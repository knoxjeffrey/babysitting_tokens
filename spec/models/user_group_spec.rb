require 'spec_helper'

describe UserGroup do
  
  it { should belong_to :user }
  it { should belong_to :group }
  
end