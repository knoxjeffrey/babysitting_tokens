class GroupInvitationsController < ApplicationController
  
  before_action :require_user
  
  def new
    @group_invitation = GroupInvitation.new
    @group = Group.find(params[:id])
  end

  def create
    @group_invitation = GroupInvitation.new((invitation_params).merge!(inviter_id: current_user.id, group_id: params[:id]))
    if @group_invitation.save
      email_invitation_to_join_group
      flash[:success] = "You have successfully sent an invitaton to #{@group_invitation.friend_email}"
      redirect_to group_path(params[:id])
    else
      @group = Group.find(params[:id])
      render :new
    end
  end
  
  private
  
  def invitation_params
    params.require(:group_invitation).permit(:friend_name, :friend_email, :message)
  end
  
  def email_invitation_to_join_group
    MyMailer.delay.send_invite(@group_invitation)
  end
  
end