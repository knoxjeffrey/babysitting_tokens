class RequestGroupsController < ApplicationController
  
  before_action :require_user
  
  def show
    @request_group = RequestGroup.find(params[:id])
  end
  
  def update
    @request_group = RequestGroup.find(params[:id])
    decision = params[:decision]
    
    if decision == "accepted"
      update_status
      set_babysitter
      set_babysitter_group
      add_tokens_to_babysitter_user_group
      credit_requester_for_unused_group_requests
      flash[:success] = "Well done, you've given a friend some well deserved time off!"
      redirect_to home_path
    elsif decision == "declined"
      update_request_decision
      redirect_to home_path
    end
  end
  
  private
  
  def update_request_decision
    DeclinedRequest.add_decision_entry(@request_group.request, current_user, @request_group.group)
  end
  # request status is changed from waiting to accepted when another group member accepts the users babysitting request
  def update_status
    @request_group.request.change_status_to_accepted
  end
  
  # sets the babysitter_id to the id of the current user that has accepted the request for a babysitter
  def set_babysitter
    @request_group.request.update_babysitter(current_user)
  end
  
  # sets the group_id to the id of the group that the request for babysitting was accepted from
  def set_babysitter_group
    @request_group.request.update_babysitter_group(@request_group.group)
  end
  
  # credit the current user tokens for accepting the request to babysit
  def add_tokens_to_babysitter_user_group
    current_user.add_tokens(@request_group)
  end
  
  # When a request for babysitting is made, it can be made to multiple groups and tokens are detucted from all those groups
  # If a request was just made to 1 group, then no further action is needed when it is accepted
  # If the request was to multiple groups, then tokens need to be added back to the requesters groups that the request was
  # not accepted from.
  def credit_requester_for_unused_group_requests
    requester_request_groups = RequestGroup.where(["request_id = ?", @request_group.request_id])
    if requester_request_groups.count > 1
      request_groups_not_accepted = requester_request_groups.reject { |request_group| request_group.group_id == @request_group.group_id }
      requester = @request_group.request.user
      request_groups_not_accepted.each { |request_group| requester.add_tokens(request_group) }  
    end
  end
  
end