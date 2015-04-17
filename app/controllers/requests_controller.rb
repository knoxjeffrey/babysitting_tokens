class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.requests_except_complete
    @friend_request_groups = current_user.friend_request_groups
    @user_groups = current_user.user_groups
    @next_babysitting_info = Request.babysitting_info(current_user).first
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.requests.build(request_params)
    if @request.valid?
      if insufficient_tokens?
        flash.now[:danger] = "Sorry, you don't have enough freedom tokens in one or more groups. Please alter your selection"
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
  
  # An array of all the requests the current user is babysitting for with status accepted
  def my_babysitting_dates
    @current_user_babysitting_for_requests = Request.babysitting_info(current_user)
  end
  
  def cancel_babysitting_date
    
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
  
  # User can make a baby sitting request to more than one of their groups.
  # If they don't have enough tokens for one of more requests then true is returned 
  def insufficient_tokens?
    current_user.has_insufficient_tokens?(array_of_group_ids_selected, @request)
  end
  
  # group_ids in params returns an empty string as the first element in the array
  # This strips the array of any empty strings
  def array_of_group_ids_selected
    request_params[:group_ids].reject { |string| string.empty? }
  end
  
  # If the user has enough tokens for all the groups they request a night out to
  # then tokens will immediately be removed from each group they are a member of
  def subtract_tokens_from_each_group_selected
    current_user.subtract_tokens(array_of_group_ids_selected, @request)
  end

end