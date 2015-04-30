require 'spec_helper'

feature "request button" do
  
  scenario "new user without invite shouldn't see request button" do
    new_user_signs_up
    new_user_signs_in
  end
  
  def new_user_signs_up
    visit register_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_full_name', with: 'Test User'
    click_button "Sign Up"
  end
  
  def new_user_signs_in
    expect(page).to have_content("Sign In")
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign In"
    expect(page).not_to have_content("Request For Freedom")
  end
  
  def email
    'test@test.com'
  end
  
  def password
    'password'
  end
end