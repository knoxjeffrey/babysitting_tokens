require 'spec_helper'

feature 'user avatar image' do
  
  scenario "user has added not avatar" do
    
    user = object_generator(:user)
    
    sign_in_user(user)
    validate_default_avatar
    
  end
  
  scenario "user has facebook authentication" do
    
    user = object_generator(:user, email: "knoxjeffrey@outlook.com")
    
    sign_in_user(user)
    authenticate_facebook
    
    validate_facebook_avatar
  end
  
  scenario "user successfully adds a new image" do
    
    user = object_generator(:user)
    
    sign_in_user(user)
    visit_edit_details
    upload_image
    
    validate_uploaded_image(user)
    
  end
  
  scenario "user attempts to upload invalid file type" do
    
    user = object_generator(:user)
    
    sign_in_user(user)
    visit_edit_details
    upload_file
    
    reject_attachment
    
  end
  
  def authenticate_facebook
    click_link "Allow Facebook Login"
  end
  
  def visit_edit_details
    click_link "Edit Details"
  end
  
  def upload_image
    attach_file "Choose Your Profile Image", "spec/support/uploads/user_image.jpg"
    click_button "Update"
  end
  
  def upload_file
    attach_file "Choose Your Profile Image", "spec/support/uploads/text_file.txt"
    click_button "Update"
  end
  
  def validate_default_avatar
    expect(page).to have_selector("img[src='http://res.cloudinary.com/da6v0vrqx/image/upload/w_100,h_100,c_fill,g_face,r_max/v1431133723/default_avatar_zdyioa.png']")
  end
  
  def validate_facebook_avatar
    expect(page).to have_selector("img[src='http://graph.facebook.com/12345/picture?width=100&height=100']")
  end
  
  def validate_uploaded_image(user)
    expect(page).to have_selector("img[src='http://res.cloudinary.com/da6v0vrqx/image/upload/w_100,h_100,c_fill,g_face,r_max/development/#{user.id}_avatar.jpg']")
  end
  
  def reject_attachment
    expect(page).to have_content("You are not allowed to upload \"txt\" files, allowed types: jpg, jpeg, gif, png")
  end
end