require 'spec_helper'

describe Request do
  it { should belong_to :user}
  
  it { should validate_presence_of :start }
  it { should validate_presence_of :finish }
end
