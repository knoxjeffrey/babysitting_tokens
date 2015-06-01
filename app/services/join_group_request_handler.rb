class JoinGroupRequestHandler
  
  def initialize(request_id)
    @request_id = request_id
  end
  
  # Clear the identifier in for the JoinGroupRequest record and join the requester to group they requested to join
  def handle_join_group_request
    @join_group_request = JoinGroupRequest.find(request_id)
    email_confirmation_joined_group
    @join_group_request.clear_identifier_column
    @join_group_request.requester.join_group(@join_group_request.group)
  end
  
  private
  
  attr_accessor :request_id
  
  def email_confirmation_joined_group
    MyMailer.delay.send_confirmation_joined_group(@join_group_request)
  end
  
end