class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.requests_except_complete
    @friend_requests = current_user.friend_requests
    @next_babysitting_info = Request.babysitting_info(current_user)
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.requests.build(request_params)
    render :new and return if !@request.valid?
    
    redirect_to my_request_path and return if insufficient_tokens?
    
    if @request.save
      flash[:success] = "You successfully created your request for freedom!"
      redirect_to home_path
    else
      render :new
    end
  end
  
  def show
    @request = Request.find(params[:id])
  end
  
  def update
    @request = Request.find(params[:id])
    update_status
    update_babysitter_id
    add_tokens_to_current_user
    flash[:success] = "Well done, you've given a friend freedom!"
    redirect_to home_path
  end
  
  private
  
  def request_params
    params.require(:request).permit(:start, :finish)
  end
  
  def insufficient_tokens?
    if current_user.has_insufficient_tokens?(@request)
      flash[:danger] = "Sorry, you don't have enough freedom tokens"
      true
    else
      false
    end
  end
  
  def update_status
    @request.update_attribute(:status, 'accepted')
  end
  
  def update_babysitter_id
    @request.update_attribute(:babysitter_id, current_user.id)
  end
  
  def add_tokens_to_current_user
    current_user.add_tokens(@request)
  end
  
end