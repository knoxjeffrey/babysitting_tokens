class AuthenticationsController < ApplicationController
  
  #Omniauth callback is routed here
  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by(provider: omniauth['provider'], uid: omniauth['uid'])
    
    # If the user is signed in an wants to associate a social account through omniauth this will create a new Authentication
    # record and associate it with the user
    if current_user
      associate_social_account_with_logged_in_user(omniauth)
    # If person already has omniauth authentication, this will be associated with the User table. Create a session cookie
    # to log the person in
    elsif authentication
      log_in_user_with_account_and_social_authentication(authentication)
    # If the user is signed out but has a user account and no facebook authentication and is trying to sign in
    elsif !!User.find_by(email: omniauth['info']['email'])
      log_in_user_with_account_but_no_social_authentication(omniauth)
    else
      # If the user is registering from the registration page. I added from=registration on the registration page link_to because
      # the call back cannot distinguish what controller the original request came from
      if request.env["omniauth.params"]['from'] == 'registration'
        register_new_user(omniauth)
      # If the user is trying to sign in from the sign in page but doesn't have a user account
      else  
        make_user_register_from_registration_page(omniauth)
      end
    end
  end
  
  private
  
  def associate_social_account_with_logged_in_user(omniauth)
    if current_user.email == omniauth['info']['email']
      current_user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      flash[:success] = "Authentication successful"
      redirect_to home_path
    else
      flash[:danger] = "Your #{omniauth['provider'].capitalize} email does match.  Please check you social credentials"
      redirect_to home_path
    end
  end
  
  def log_in_user_with_account_and_social_authentication(authentication)
    session[:user_id] = authentication.user.id #this is backed by the browsers cookie to track if the user is authenticated
    redirect_to home_path
  end
  
  def log_in_user_with_account_but_no_social_authentication(omniauth)
    user = User.find_by(email: omniauth['info']['email'])
    user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
    session[:user_id] = user.id
    flash[:success] = "You now have #{omniauth['provider'].capitalize} login authenticated"
    redirect_to home_path
  end
  
  def register_new_user(omniauth)
    user = new_user(omniauth)
    
    #follow the same flow as UsersController create action
    if user.save
      user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      check_for_invitation(user, request.env["omniauth.params"]['invite']) #invite added into link_to arguments from registration page
      send_welcome_email(user)
      redirect_to sign_in_path
    else
      flash[:danger] = "Sorry we could not create an account using #{omniauth['provider'].capitalize}. Please use another registration method."
      redirect_to controller: 'users', action: 'new'
    end
  end
  
  def new_user(omniauth)
    email = omniauth['info']['email']
    full_name = omniauth['info']['name']
    password = SecureRandom.urlsafe_base64
    User.new(email: email, full_name: full_name, password: password, password_confirmation: password)
  end
  
  def make_user_register_from_registration_page(omniauth)
    flash[:danger] = "Sorry you have not registered a #{omniauth['provider'].capitalize} account for this site. Please register below."
    redirect_to register_path
  end
    
end