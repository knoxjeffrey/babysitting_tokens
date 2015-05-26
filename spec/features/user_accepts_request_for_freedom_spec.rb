require 'spec_helper'

feature "user accepts date for freedom" do
  
  background do
    current_user = object_generator(:user)
    friend_user = object_generator(:user)
    group = object_generator(:group)
    group_member1 = object_generator(:user_group, user: current_user, group: group) 
    group_member2 = object_generator(:user_group, user: friend_user, group: group) 
    request1 = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 22:00:00", user: friend_user, group_ids: group.id)
    sign_in_user(current_user)
  end
  
  scenario "user presses accept button" do
    expect_page_to_have_see_details_button
    press_see_details_button
    press_accept_button
    expect_current_path_to_be_home_path
    expect_page_not_to_have_open_button
  end
  
  def expect_page_to_have_see_details_button
    expect(page).to have_content("Click For Details")
  end
  
  def press_see_details_button
    click_link "Click For Details"
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