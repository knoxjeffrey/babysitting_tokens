class RequestGroupsController < ApplicationController
  
  before_action :require_user
  
  def show
    @request_group = RequestGroup.find(params[:id])
  end
  
  def update
    @request_group = RequestGroup.find(params[:id])
    update_status
    set_babysitter
    set_babysitter_group
    add_tokens_to_babysitter_user_group
    credit_requester_for_unused_group_requests
    flash[:success] = "Well done, you've given a friend freedom!"
    redirect_to home_path
  end
  
  private
  
  # request status is changed from waiting to accepted when another group member accepts the users babysitting request
  def update_status
    @request_group.request.change_status_to_accepted
  end
  
  # sets the babysitter_id to the id of the current user that has accepted the request for a babysitter
  def set_babysitter
    @request_group.request.update_babysitter(current_user)
  end
  
  def set_babysitter_group
    @request_group.request.update_babysitter_group(@request_group.group)
  end
  
  def add_tokens_to_babysitter_user_group
    current_user.add_tokens(@request_group)
  end
  
  def credit_requester_for_unused_group_requests
    requester_request_groups = RequestGroup.where(["request_id = ?", @request_group.request_id])
    if requester_request_groups.count > 1
      request_groups_not_accepted = requester_request_groups.reject { |request_group| request_group.group_id == @request_group.group_id }
      requester = @request_group.request.user
      request_groups_not_accepted.each { |request_group| requester.add_tokens(request_group) }  
    end
  end
  
end