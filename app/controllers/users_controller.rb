class UsersController < ApplicationController
  
  before_action :require_user, only: [:show, :search]
  
  def new
    redirect_to home_path and return if logged_in?
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      check_for_invitation(@user, params[:group_invitation_identifier])
      send_welcome_email(@user)
      redirect_to sign_in_path
    else
      render :new
    end
  end 
  
  def show
    @user  = User.find(params[:id])
  end
  
  def new_invitation_with_identifier
    group_invitation = GroupInvitation.find_by_identifier(params[:identifier])
    if group_invitation
      check_if_group_invitation_is_to_new_or_existing_user(group_invitation)
    else
      redirect_to expired_identifier_path
    end
  end
  
  def search
    @search_results = User.search_by_friend_full_name(params[:full_name], current_user)
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end
  
  # If the invited group member is already a user then simply add them as a member to the group they were invited to
  # If invited user is new to the site then they need to register first before they are added as a group member
  def check_if_group_invitation_is_to_new_or_existing_user(group_invitation)
    if User.find_by_email(group_invitation.friend_email)
      user = User.find_by_email(group_invitation.friend_email)
      GroupInvitationHandler.new(user: user, group_invitation_identifier: group_invitation.identifier).handle_group_invitation
      redirect_to home_path
    else
      @user = User.new(email: group_invitation.friend_email)
      @group_invitation_identifier = group_invitation.identifier
      render :new
    end
  end
  
end