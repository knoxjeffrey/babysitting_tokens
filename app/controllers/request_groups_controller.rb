class RequestGroupsController < ApplicationController
  
  before_action :require_user
  
  def show
    @request_group = RequestGroup.find(params[:id])
  end
  
  def update
    @request_group = RequestGroup.find(params[:id])
    update_status
    update_babysitter_id
    add_tokens_to_babysitter_user_group
    #credit_requesters
    flash[:success] = "Well done, you've given a friend freedom!"
    redirect_to home_path
  end
  
  private
  
  # request status is changed from waiting to accepted when another group member accepts the users babysitting request
  def update_status
    @request_group.request.update_attribute(:status, 'accepted')
  end
  
  # sets the babysitter_id to the id of the current user that has accepted the request for a babysitter
  def update_babysitter_id
    @request_group.request.update_attribute(:babysitter_id, current_user.id)
  end
  
  def add_tokens_to_babysitter_user_group
    current_user.add_tokens(@request_group)
  end
  
end