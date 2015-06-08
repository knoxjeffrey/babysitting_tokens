class PagesController < ApplicationController
  
  def index
    if logged_in?
      redirect_to home_path 
    else
      render :layout => false
    end
  end
  
  def expired_identifier; end
  
  def instructions; end
  
  def about; end
  
  def privacy; end
  
  def have_fun
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
  
  def time_off
    if logged_in?
      redirect_to home_path 
    else
      render :layout => false
    end
  end
  
end