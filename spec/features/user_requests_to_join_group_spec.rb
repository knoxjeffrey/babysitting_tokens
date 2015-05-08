require 'spec_helper'

feature "user requests to join group" do
  
  scenario "user requests to join group and is accepted" do
    clear_emails
    
    requester = object_generator(:user, full_name: "Requesting User")
    group_member = object_generator(:user, full_name: "Jeff Knox")
    group = object_generator(:group, group_name: 'Test Group')
    user_group = object_generator(:user_group, user: group_member, group: group)
    
    sign_in_user(requester)
    search_for_friend
    request_to_join_group

    sign_out
    sign_in_user(group_member)
    
    accept_invitation
    
    check_new_user_is_in_group
  end
  
  def search_for_friend
    fill_in "full_name", with: "Jeff Knox"
    click_button "search-btn"
    expect(page).to have_content("Jeff Knox")
  end
  
  def request_to_join_group
    click_link "Groups"
    click_link "Request To Join Group"
  end
  
  def accept_invitation
    visit("#{MandrillMailer.deliveries.first.message["global_merge_vars"].third["content"]}")
    click_link "Accept Request"
    expect(current_path).to eq(home_path)
  end
  
  def check_new_user_is_in_group
    click_link "Test Group"
    expect(page).to have_content("Requesting User")
  end
  
end