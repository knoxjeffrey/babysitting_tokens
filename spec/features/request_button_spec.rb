require 'spec_helper'

feature "request button" do
  
  scenario "new user without a group shouldn't see request button" do
    new_user_signs_up
    new_user_signs_in
  end
  
  scenario "any user that is a member of a group should see request button" do
    new_user_signs_up
    new_user_signs_in
    create_new_group
    expect(page).to have_content("I Need A Sitter")
  end
  
  def new_user_signs_up
    visit register_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_full_name', with: 'Test User'
    click_button "Register"
  end
  
  def new_user_signs_in
    fill_in "email", with: email
    fill_in "password", with: password
    click_button "Sign In"
    expect(page).not_to have_content("I Need A Sitter")
  end
  
  def email
    'test@test.com'
  end
  
  def password
    'password'
  end
end