class AuthenticationsController < ApplicationController
  
  #Omniauth callback is routed here
  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by(provider: omniauth['provider'], uid: omniauth['uid'])
    
    # If person already has omniauth authentication, this will be associated with the User table. Create a session cookie
    # to log the person in
    if authentication
      session[:user_id] = authentication.user.id #this is backed by the browsers cookie to track if the user is authenticated
      redirect_to home_path
    # If the user is signed in an wants to associated a social account through omniauth this will create a new Authentication
    # record and associate it with the user
    elsif current_user
      current_user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      flash[:success] = "Authentication successful"
      redirect_to home_path
    else
      # If the user is registering from the registration page. I added from=registration on the registration page link_to because
      # the call back cannot distinguish what controller the original request came from
      if request.env["omniauth.params"]['from'] == 'registration'
        email = omniauth['info']['email']
        full_name = omniauth['info']['name']
        password = SecureRandom.urlsafe_base64
        user = User.new(email: email, full_name: full_name, password: password, password_confirmation: password)
        
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
      # If the user is trying to sign in from the sign in page but doesn't have a user account
      else  
        flash[:danger] = "Sorry you have not registered a #{omniauth['provider'].capitalize} account for this site. Please register below."
        redirect_to register_path
      end
    end
  end
    
end