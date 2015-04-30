require 'spec_helper'

feature "user invites friend" do
  scenario "user successfully invites friend and is accepted" do
    clear_emails
    
    inviter = object_generator(:user)
    
    sign_in_user(inviter)
    
    create_new_group
    user_invites_friend
    
    click_accept_invitation
    friend_signs_up
    friend_signs_in
  end
  
  def user_invites_friend
    click_link "Details"
    click_link "Invite A Friend To This Group"
    
    fill_in "group_invitation_friend_name", with: friend_name
    fill_in "group_invitation_friend_email", with: friend_email
    fill_in "group_invitation_message", with: "Come join my babysitting group"
    click_button "Send Invitation"
    sign_out
  end
  
  def friend_email
    'friend@test.com'
  end
  
  def friend_name
    'My Friend'
  end
  
  def click_accept_invitation
    visit("#{MandrillMailer.deliveries.first.message["global_merge_vars"].third["content"]}")
  end
  
  def friend_signs_up
    fill_in_password
    fill_in 'user_full_name', with: friend_name
    click_button "Sign Up"
  end
  
  def friend_signs_in
    expect(page).to have_content("Sign In")
    fill_in "Email", with: friend_email
    fill_in_password
    click_button "Sign In"
    expect(page).to have_content("Test Group")
  end
  
  def fill_in_password
    fill_in 'Password', with: friend_password
  end
  
  def friend_password
    'password'
  end

end