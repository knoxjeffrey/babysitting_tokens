class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.requests_except_complete
    @friend_requests = current_user.friend_requests
    @user_groups = current_user.user_groups
    @next_babysitting_info = Request.babysitting_info(current_user)
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.requests.build(request_params)
    if @request.valid?
      if insufficient_tokens?
        flash.now[:danger] = "Sorry, you don't have enough freedom tokens in one or more groups"
        render :new
      else
        @request.save
        subtract_tokens_from_each_group_selected
        flash[:success] = "You successfully created your request for freedom!"
        redirect_to home_path
      end
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
  
  # If a user is only a member of one group I don't want them to have to keep checking a box for their group
  # when making a request. In this case there will be no group option and group_ids will be merged in with 
  # the id of the group they are a member of
  def request_params
    if params[:request][:group_ids].present?
      params.require(:request).permit(:start, :finish, group_ids: [])
    else
      params.require(:request).permit(:start, :finish).merge!(group_ids: ["#{current_user.user_groups.first.group_id}"])
    end
  end
  
  def insufficient_tokens?
    current_user.has_insufficient_tokens?(array_of_group_ids_selected, @request)
  end
  
  def array_of_group_ids_selected
    request_params[:group_ids].reject { |string| string.empty? }
  end
  
  def subtract_tokens_from_each_group_selected
    current_user.subtract_tokens(array_of_group_ids_selected, @request)
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