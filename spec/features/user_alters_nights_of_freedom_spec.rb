require 'spec_helper'

feature "user alters nights of freedom" do
  
  let(:user) { object_generator(:user) }
  let(:friend) { object_generator(:user) }
  let!(:group) { object_generator(:group, admin: user) }
  let!(:group_member1) { object_generator(:user_group, user: user, group: group) }
  let!(:group_member2) { object_generator(:user_group, user: friend, group: group) }
  
  scenario "user edits request that has not been accepted" do
    request = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 21:00:00", user: user, group_ids: group.id)
    
    sign_in_user(user)
    click_link "Click For Details"
    expect_to_see_edit_and_delete_buttons
    edit_request
  end
  
  scenario "user deletes request that has been accepted" do
    request = object_generator(:request, start: "2030-03-17 19:00:00", finish: "2030-03-17 21:00:00", status: 'accepted', user: user, group_ids: group.id, babysitter_id: friend.id, group_id: group.id)
    
    sign_in_user(user)
    click_link "Click For Details"
    expect_to_see_only_delete_button
    delete_request
  end
  
  def expect_to_see_edit_and_delete_buttons
    expect(page).to have_link("Edit", exact: true)
    expect(page).to have_link('Delete')
  end
  
  def expect_to_see_only_delete_button
    expect(page).not_to have_link("Edit", exact: true)
    expect(page).to have_link('Delete')
  end
  
  def edit_request
    click_link 'Edit'
    fill_in 'datetimepicker1', with: "2030-03-17 19:00:00"
    fill_in 'datetimepicker2', with: "2030-03-17 23:00:00"
    click_button "Update Request"
    expect(page).to have_content("Mar 17th, 2030")
    expect(page).to have_content('18') # to represent the change in tokens needed for the longer request
  end
  
  def delete_request
    click_link 'Delete'
    expect(page).not_to have_content("Mar 17th, 2030")
    expect(page).to have_content('22') # to represent the tokens being reallocated to the current user due to cancelation
  end
  
end