class PagesController < ApplicationController
  
  def index
    redirect_to home_path if logged_in?
  end
  
  def expired_identifier; end
  
  def instructions; end
  
  def about; end
  
  def privacy; end
  
  def night_out
    if logged_in?
      redirect_to home_path 
    else
      render :layout => false
    end
  end
  
  def dinner_without_kids
    if logged_in?
      redirect_to home_path 
    else
      render :layout => false
    end
  end
  
end