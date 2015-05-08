require 'spec_helper'

feature "user only sees their groups" do
  
  scenario "user signs in and only sees the groups they are a member of" do

    user = object_generator(:user, full_name: "Current User")
    other_user1 = object_generator(:user, full_name: "Current User")
    other_user2 = object_generator(:user, full_name: "Current User")
    
    group1 = object_generator(:group, group_name: 'Current User Group1', admin: user)
    group2 = object_generator(:group, group_name: 'Current User Group2', admin: user)
    group3 = object_generator(:group, group_name: 'Other User 1 Group', admin: other_user1)
    group4 = object_generator(:group, group_name: 'Other User 2 Group', admin: other_user2)
    
    user_group1 = object_generator(:user_group, user: user, group: group1)
    user_group2 = object_generator(:user_group, user: user, group: group2)
    user_group3 = object_generator(:user_group, user: other_user1, group: group3)
    user_group4 = object_generator(:user_group, user: other_user2, group: group4)
    
    sign_in_user(user)
    expect_to_only_see_current_user_groups
    
  end
    
  def expect_to_only_see_current_user_groups
    expect(page).to have_content("Current User Group1")
    expect(page).to have_content("Current User Group2")
    expect(page).not_to have_content("Other User 1 Group")
    expect(page).not_to have_content("Other User 2 Group")
  end
  
end