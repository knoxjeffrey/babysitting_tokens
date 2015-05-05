class JoinGroupInvitationhandler
  
  def initialize(options={})
    @requester = options[:requester]
    @identifier = options[:identifier]
  end
  
  def handle_join_group_request
    join_group_request = JoinGroupRequest.find_by(identifier: identifier)
    join_group_request.clear_identifier_column
    requester.add_to_group(join_group_request.group)
  end
  
  private
  
  attr_reader :identifier, :user
  
end