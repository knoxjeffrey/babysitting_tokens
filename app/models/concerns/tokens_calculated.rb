module TokensCalculated
  extend ActiveSupport::Concern
  
  # Each full hour of babysitting amounts to 1 token
  # eg  1 hour = 1 token
  #     1 hour 59 mins = 1 token
  def tokens_for_request(request)
    ((request.finish - request.start) / 1.hour).round
  end

end