require 'spec_helper'

feature "user searches" do
  
  background do
    object_generator(:user, full_name: "Jeff Knox")
    sign_in_user
  end
  
  scenario "user searches for someone that isn't present" do
    fill_in :full_name, with: "Kenny"
    click_button "Search"
    expect(current_path).to eq(search_users_path)
    expect(page).to have_content /no results/i
  end
  
  scenario "user searches for someone with exact full name" do
    fill_in :full_name, with: "Jeff Knox"
    click_button "Search"
    expect(current_path).to eq(search_users_path)
    expect(page).to have_content("Jeff Knox")
  end
  
  scenario "user searches for someone with partial full name" do
    fill_in :full_name, with: "ff"
    click_button "Search"
    expect(current_path).to eq(search_users_path)
    expect(page).to have_content("Jeff Knox")
  end
  
end