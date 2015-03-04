require 'spec_helper'

feature "user accepts date for freedom" do
  
  background do
    friend_user = object_generator(:user)
    request1 = object_generator(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", user: friend_user)
    sign_in_user
  end
  
  scenario "user presses accept button" do
    expect_page_to_have_open_button
    press_open_button
    press_accept_button
    expect_current_path_to_be_home_path
    expect_page_not_to_have_open_button
  end
  
  def expect_page_to_have_open_button
    expect(page).to have_content("Open")
  end
  
  def press_open_button
    click_link "Open"
  end
  
  def press_accept_button
    click_button "Accept"
  end
  
  def expect_current_path_to_be_home_path
    expect(current_path).to eq(home_path)
  end
  
  def expect_page_not_to_have_open_button
    expect(page).not_to have_content("Open")
  end
  
end