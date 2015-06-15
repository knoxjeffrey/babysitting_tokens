class RequestGroup < ActiveRecord::Base
  include TokensCalculated
  
  belongs_to :request
  belongs_to :group
  
  # Returns the number of tokens allocated for a request
  def tokens_for_babysitter
    tokens_for_request(self.request)
  end
  
  def has_request_been_declined(current_user)
    current_user.declined_requests.each do |declined|
      return true if declined.request_id == self.request_id && declined.group_id == self.group_id
    end
    false
  end
  
end