class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.requests_except_complete
    @friend_requests = current_user.friend_requests
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.requests.build(request_params)

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
  
  private
  
  def request_params
    params.require(:request).permit(:start, :finish)
  end
  
end