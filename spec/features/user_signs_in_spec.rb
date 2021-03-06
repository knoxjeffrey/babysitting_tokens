require 'spec_helper'

feature "user signs in" do

  given(:valid_user) { object_generator(:user) }
  
  scenario "with existing email and correct password" do
    sign_in_user(valid_user)
    expect_drop_down_to_contain_full_name(valid_user)
  end
  
  scenario "with incorrect login details" do
    visit sign_in_path
    enter_incorrect_login_details(valid_user)
    click_button "Sign In"
    expect_to_return_to_sign_in_page_and_see_error
  end
  
  def expect_drop_down_to_contain_full_name(user)
    expect(page.find('.dropdown .dropdown-toggle').text).to have_content user.full_name
  end
  
  def enter_incorrect_login_details(user)
    fill_in "Email", with: user.email
    fill_in "Password", with: "totally wrong password"
  end
  
  def expect_to_return_to_sign_in_page_and_see_error
    expect(current_path).to eq(sign_in_path)
    expect(page).to have_content "There is a problem with your username or password"
  end
end