class PasswordResetsController < ApplicationController
  
  def show
    user = User.where(password_token: params[:id]).first
    
    if user
      @password_token = user.password_token
    else
      redirect_to expired_password_token_path
    end
  end
  
  def create
    user = User.where(password_token: params[:password_token]).first
    if user
      user.password = params[:password]
      
      if user.save
        user.remove_password_token!
        flash[:success] = "Your password has been changed, please sign in"
        redirect_to sign_in_path
      else
        @user = user
        @password_token = params[:password_token]
        render :show
      end
    else
      redirect_to expired_password_token_path
    end
  end
  
end