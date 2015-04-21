class RequestGroup < ActiveRecord::Base
  include TokensCalculated
  
  belongs_to :request
  belongs_to :group
  
  # Returns the number of tokens allocated for a request
  def tokens_for_babysitter
    tokens_for_request(self.request)
  end
  
end