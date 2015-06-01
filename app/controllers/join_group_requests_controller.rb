class JoinGroupRequestsController < ApplicationController
  
  before_action :require_user
  
  def create
    if JoinGroupRequest.find_by(requester_id: current_user.id, group_member_id: params[:user_id], group_id: params[:group_id])
      flash[:danger] = "You have already sent a request to join this group"
    else
      @request_to_join_group = JoinGroupRequest.create(requester_id: current_user.id, group_member_id: params[:user_id], group_id: params[:group_id])
      email_request_to_join_group
      flash[:success] = "You have successfully sent a request to #{@request_to_join_group.group_member.full_name} 
                          to join #{@request_to_join_group.group.group_name}"
    end
    redirect_to user_path(params[:user_id])
  end
    
  def show
    @join_group_request = JoinGroupRequest.find_by_identifier(params[:identifier])
    if @join_group_request
      email_confirmation_joined_group
    else
      redirect_to expired_identifier_path
    end
  end
  
  private
  
  def email_request_to_join_group
    MyMailer.delay.send_request_to_join_group(@request_to_join_group)
  end
  
  def email_confirmation_joined_group
    MyMailer.delay.send_confirmation_joined_group(@join_group_request)
  end
  
end