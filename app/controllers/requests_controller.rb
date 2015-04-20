class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.waiting_and_accepted_requests
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
  
  def edit
    @request = Request.find(params[:id])
  end
  
  # Entry in Request table is updated and all associated entries in RequestGroup table are automatically updated - this includes adding and deleting entries. 
  def update
    @request = Request.find(params[:id])
    
    if @request.status == "waiting"
      @request.assign_attributes(request_params)
      if @request.valid?
        if insufficient_tokens?
          flash.now[:danger] = "Sorry, you don't have enough freedom tokens in one or more groups. Please alter your selection"
          render :update
        else
          @request.save
          flash[:success] = "You successfully altered your request for freedom!"
          redirect_to home_path
        end
      else
        render :update
      end
    else
      flash.now[:danger] = "Sorry, you cannot update a request after it has been accepted."
      redirect_to home_path
    end
  end
  
  def destroy
    @request = Request.find(params[:id])
    Request.destroy(@request.id)
    redirect_to home_path
  end
  
  # An array of all the requests the current user is babysitting for with status accepted
  def my_babysitting_dates
    @current_user_babysitting_for_requests = Request.babysitting_info(current_user)
  end
  
  # Cancels the agreement by the current user to babysit by clearing the columns for babysitter_id and group_id in the request
  # and sets the status of the request back to waiting
  # Deducts the tokens from the current user group they were allocated for agreeing to babysit
  # Deduct the tokens from all the requesters groups that the original request was made to except the user group that the 
  # request had originally been accepted from
  def cancel_babysitting_date
    request = Request.find(params[:id])
    deduct_tokens_from_current_user(request)
    deduct_tokens_from_original_request_groups_not_accepted(request)
    request.cancel_babysitting_agreement
    flash[:danger] = "You have cancelled your date to babysit.  We will let the other person know"
    redirect_to my_babysitting_dates_path
  end
  
  private
  
  # If a user is only a member of one group I don't want them to have to keep checking a box for their group
  # when making a request. In this case there will be no group option and group_ids will be merged in with 
  # the id of the only group they are a member of
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
  
  # After checking if the user has enough tokens for all the groups they request a night out to
  # then tokens will immediately be removed from each group they are a member of
  def subtract_tokens_from_each_group_selected
    current_user.subtract_tokens(array_of_group_ids_selected, @request)
  end
  
  # Deducts the tokens from the current user they were given for agreeing to babysit
  def deduct_tokens_from_current_user(request)
    current_user.subtract_tokens([request.group_id], request)
  end
  
  #Deduct the tokens from all the requesters groups that the original request was made to except the user group that the 
  # request had originally been accepted from
  def deduct_tokens_from_original_request_groups_not_accepted(request)
    selected_group_ids = request.groups_original_request_not_accepted_from
    request.user.subtract_tokens(selected_group_ids, request)
  end

end