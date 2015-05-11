class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.waiting_and_accepted_requests
    @friend_request_groups = current_user.friend_request_groups
    @next_babysitting_info = Request.babysitting_info(current_user).first
  end
  
  def new
    @request = Request.new
  end
  
  def create
    @request = current_user.requests.build(request_params)
    if @request.valid?
      check_if_enough_tokens_for_request
    else
      render :new
    end
  end
  
  def edit
    @request = Request.find(params[:id])
  end
  
  # Entry in Request table is updated and all associated entries in RequestGroup table are automatically updated. Only requests
  # that have not been accepted can be updated
  def update
    @request = Request.find(params[:id])
    # I need to hold onto the details of the original request in order to compare against the updated request.  This way I can check
    # what groups are the same, removed, or added in the updated request. I need this to allow me to reallocate, credit or deduct tokens
    original_request = Request.find(params[:id])
    original_groups_in_request = original_request.groups.map { |group| group }

    ActiveRecord::Base.transaction do
      if @request.status == "waiting"
        update_request_if_valid(original_request, original_groups_in_request)
      else
        flash.now[:danger] = "Sorry, you cannot update a request after it has been accepted."
        redirect_to home_path
      end
    end
  end
  
  # Requests that are waiting to be accepted or have been accepted can be deleted
  def destroy
    @request = Request.find(params[:id])
    
    if @request.status == 'waiting'
      add_tokens_to_current_user_groups_request_was_made_to
    elsif @request.status == 'accepted'
      add_tokens_to_current_user_group_request_was_accepted_from
      deduct_tokens_from_friend_user_group_request_was_accepted_from
    end
    
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
    send_cancelation_notification_email(request)
    deduct_tokens_from_current_user(request)
    deduct_tokens_from_original_request_groups_not_accepted(request)
    request.cancel_babysitting_agreement
    flash[:danger] = "You have cancelled your date to babysit.  Babysitting Tokens will let the other person know"
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
  
  # If there are enough tokens to make the request then subtract those tokens from all the groups the request was made to
  def check_if_enough_tokens_for_request
    if insufficient_tokens?
      flash.now[:danger] = "Sorry, you don't have enough freedom tokens in one or more groups. Please alter your selection"
      render :new
    else
      @request.save
      email_users_of_each_group_selected
      subtract_tokens_from_each_group_selected
      flash[:success] = "You successfully created your request for freedom!"
      redirect_to home_path
    end
  end
  
  # Only persit the update if all paramaters are valid
  def update_request_if_valid(original_request, original_groups_in_request)
    if @request.update(request_params)
      check_if_enough_tokens_for_edited_request(original_request, original_groups_in_request)
    else
      render :edit
      raise ActiveRecord::Rollback
    end
  end
  
  def check_if_enough_tokens_for_edited_request(original_request, original_groups_in_request)
    if insufficient_tokens?
      flash.now[:danger] = "Sorry, you don't have enough freedom tokens in one or more groups. Please alter your selection"
      render :edit
      raise ActiveRecord::Rollback
    else
      reallocate_updated_request_tokens(original_request, original_groups_in_request)
      flash[:success] = "You successfully altered your request for freedom!"
      redirect_to home_path
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
  
  def email_users_of_each_group_selected
    @request.email_request_to_group_members(array_of_group_ids_selected)
  end
  
  # Deducts the tokens from the current user they were given for agreeing to babysit
  def deduct_tokens_from_current_user(request)
    current_user.subtract_tokens([request.group_id], request)
  end
  
  # Deduct the tokens from all the requesters groups that the original request was made to except the user group that the 
  # request had originally been accepted from
  def deduct_tokens_from_original_request_groups_not_accepted(request)
    selected_group_ids = request.groups_original_request_not_accepted_from
    request.user.subtract_tokens(selected_group_ids, request)
  end
  
  # Adds tokens back to the current user groups they made a request to.  Only use this if the request is still waiting to
  # be accepted
  def add_tokens_to_current_user_groups_request_was_made_to
    if @request.status == 'waiting'
      array_of_request_groups = @request.groups_request_was_made_to
      array_of_request_groups.each { |request_group| current_user.add_tokens(request_group)}
    end
  end
  
  # Adds tokens back to current user for their group they had their request accepted from. Only use when request has been accepted
  def add_tokens_to_current_user_group_request_was_accepted_from
    if @request.status == 'accepted'
      request_group = @request.group_request_was_accepted_by
      current_user.add_tokens(request_group)
    end
  end
  
  # Deducts tokens from the friend that had accepted the current users request from their group. Only use when request has been accepted
  def deduct_tokens_from_friend_user_group_request_was_accepted_from
    if @request.status == 'accepted'
      user = User.find(@request.babysitter_id)
      user.subtract_tokens([@request.group_id], @request)
    end
  end
  
  # If the same group is in request then calculated diff in tokens between old and updated request and then reallocate those tokens
  # For groups taken out of the request, add the tokens, based on the original request, back to those groups
  # For new groups added to the request, deduct the tokens, based on the new request, from those groups
  def reallocate_updated_request_tokens(original_request, original_groups_in_request)
    reallocate_tokens_for_same_groups_in_request(original_request, original_groups_in_request)
    credit_tokens_for_groups_no_longer_in_request(original_request, original_groups_in_request)
    deduct_tokens_for_new_groups_in_request(original_request, original_groups_in_request)
  end
  
  # Only if there are the same groups in the old and updated request should tokens be reallocated
  def reallocate_tokens_for_same_groups_in_request(original_request, original_groups_in_request)
    token_difference = @request.calculate_token_difference_between_original_and_old_request(original_request)
    same_groups_in_request = original_groups_in_request.select { |group| group if @request.groups.include? group }
    same_groups_in_request.each { |group| current_user.reallocate_tokens(group, token_difference) } if same_groups_in_request.present?
  end
  
  # Only if there are no longer groups in the updated request that were in the original should tokens be added back
  def credit_tokens_for_groups_no_longer_in_request(original_request, original_groups_in_request)
    tokens_for_old_request = original_request.calculate_tokens_for_request
    groups_no_longer_in_request = original_groups_in_request.reject { |group| group if @request.groups.include? group }
    groups_no_longer_in_request.each { |group| current_user.reallocate_tokens(group, tokens_for_old_request) } if groups_no_longer_in_request.present?
  end
  
  # Only if there are groups that are in the updated request that were not in the original request should tokne be deducted
  def deduct_tokens_for_new_groups_in_request(original_request, original_groups_in_request)
    tokens_for_new_request = @request.calculate_tokens_for_request
    new_groups_in_request = @request.groups.reject { |group| group if original_groups_in_request.include? group }
    new_groups_in_request.each { |group| current_user.reallocate_tokens(group, -tokens_for_new_request) } if new_groups_in_request.present?
  end
  
  def send_cancelation_notification_email(request)
    MyMailer.delay.notify_user_that_babysitter_canceled(request)
  end

end