# only for features. Creates a user and signs them in so they are on the home path
module FeatureSessionHelper
  
  def sign_in_user(a_user=nil)
    a_user ||= object_generator(:user)
    visit sign_in_path
    fill_in :email, with: a_user.email
    fill_in :password, with: a_user.password
    click_button "Sign In"
    expect(current_path).to eq(home_path)
  end
  
  def create_new_group
    click_link "Create New Circle"
    fill_in "group_group_name", with: "Test Group"
    fill_in "group_location", with: "Scotland"
    click_button "Create"
  end
  
  def sign_out
    visit sign_out_path
  end
  
  def clear_emails
    MandrillMailer.deliveries.clear 
  end
  
end