require 'spec_helper'

feature "user accepts date for freedom" do
  
  background do
    friend_user = object_generator(:user)
    request1 = object_generator(:request, start: "2015-03-17 19:00:00", finish: "2015-03-17 22:00:00", user: friend_user)
    sign_in_user
  end
  
  scenario "user presses accept button" do
    expect(page).to have_content("Mar 17th, 2015")
    press_open_button
    press_accept_button
    expect(current_path).to eq(home_path)
    expect(page).not_to have_content("Mar 17th, 2015")
  end
  
  def press_open_button
    click_link "Open"
  end
  
  def press_accept_button
    click_button "Accept"
  end
  
end