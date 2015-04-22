class UsersController < ApplicationController
  
  def new
    redirect_to home_path and return if logged_in?
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      InvitationMailer.notify_on_user_signup(@user).deliver
      redirect_to sign_in_path
    else
      render :new
    end
  end 
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end
  
end