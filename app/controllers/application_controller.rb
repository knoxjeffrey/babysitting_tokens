class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  #allow these methods to be used in the views as well
  helper_method :current_user, :logged_in?
  
  def current_user
    #if there's an authenticated user, return the user obj
    #else return nil
    #
    #uses memoization to stop the database being hit every time current_user method is called.  
    #If it's the first call then the database is hit and subsequent calls will use the value stored in the @current_user instance variable
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  #takes the current_user method and turns it into a boolean.  !!nil returns false 
  def logged_in?
    !!current_user 
  end
  
  def require_user
    if !logged_in?
      redirect_to root_path
    end
  end
  
  # Handles the case when a new user joined from an invite from another user
  def check_for_invitation(user, identifier)
    if identifier.present?
      GroupInvitationHandler.new(user: user, group_invitation_identifier: identifier).handle_group_invitation
    end
  end
  
  def send_welcome_email(user)
    MyMailer.delay.notify_on_user_signup(user)
  end
end
