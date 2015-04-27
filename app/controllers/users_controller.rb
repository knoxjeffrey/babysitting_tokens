class UsersController < ApplicationController
  
  def new
    redirect_to home_path and return if logged_in?
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      check_for_invitation
      send_welcome_email
      redirect_to sign_in_path
    else
      render :new
    end
  end 
  
  def new_invitation_with_identifier
    group_invitation = GroupInvitation.find_by_identifier(params[:identifier])
    if group_invitation
      @user = User.new(email: group_invitation.friend_email)
      @group_invitation_identifier = group_invitation.identifier
      render :new
    else
      redirect_to expired_identifier_path
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end
  
  def check_for_invitation
    if params[:group_invitation_identifier].present?
      GroupInvitationHandler.new(user: @user, group_invitation_identifier: params[:group_invitation_identifier]).handle_group_invitation
    end
  end
  
  def send_welcome_email
    MyMailer.delay.notify_on_user_signup(@user)
  end
  
end