class UserGroupsController < ApplicationController
  
  before_action :require_user
  
  def create
    JoinGroupRequestHandler.new(params[:request_id]).handle_join_group_request
    person_to_join = JoinGroupRequest.find(params[:request_id]).requester
    flash[:success] = "You have successfully added #{person_to_join.full_name}"
    redirect_to home_path
  end
  
end