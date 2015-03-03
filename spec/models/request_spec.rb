require 'spec_helper'

describe Request do
  it { should belong_to :user}
  
  it { should validate_presence_of :start }
  it { should validate_presence_of :finish }
  
  it "has a default status value of waiting" do
    new_request = object_generator(:request)
    
    expect(new_request.status).to eq('waiting')
  end
end
