class SessionsController < ApplicationController
  
  def new
    redirect_to home_path if logged_in?
  end
  
  def create
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      login_user!(user)
    else
      flash[:danger] = "There is a problem with your username or password"
      redirect_to sign_in_path
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path 
  end
  
  private
  
  def login_user!(user)
    session[:user_id] = user.id #this is backed by the browsers cookie to track if the user is authenticated
    redirect_to home_path
  end
  
end