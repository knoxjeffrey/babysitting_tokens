require 'spec_helper'

feature "user picks new date of freedom" do
  
  background do
    sign_in_user
  end
  
  scenario "user fills in start and finish times and dates" do
    press_pick_freedom_date_button
    enter_start_date("20/03/2015 18:00")
    enter_finish_date("20/03/2015 23:00")
    press_freedom_button
    expect(current_path).to eq(home_path)
    expect(page).to have_content("Mar 20th, 2015")
  end
  
  scenario "user fills in start and finish times and dates with not enough tokens" do
    press_pick_freedom_date_button
    enter_start_date("20/03/2015 18:00")
    enter_finish_date("20/03/2020 23:00")
    press_freedom_button
    expect(current_path).to eq(my_request_path)
  end
  
  def press_pick_freedom_date_button
    click_link "Pick Your Next Day Of Freedom"
  end
  
  def enter_start_date(date)
    fill_in 'datetimepicker1', with: date
  end
  
  def enter_finish_date(date)
    fill_in 'datetimepicker2', with: date
  end
  
  def press_freedom_button
    click_button "Freedom"
  end
  
  
end