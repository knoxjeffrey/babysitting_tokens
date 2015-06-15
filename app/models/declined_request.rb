class DeclinedRequest < ActiveRecord::Base
  
  belongs_to :request
  belongs_to :user
  belongs_to :group
  
  # all requests that have been declined are logged here
  def self.add_decision_entry(request, user, group)
    self.create(request_id: request.id, user_id: user.id, group_id: group.id)
  end
  
end