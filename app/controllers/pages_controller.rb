class PagesController < ApplicationController
  
  def index
    redirect_to home_path if logged_in?
  end
  
  def expired_identifier; end
  
  def instructions; end
  
  def about; end
  
  def privacy; end
  
end