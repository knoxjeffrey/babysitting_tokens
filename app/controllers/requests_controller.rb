class RequestsController < ApplicationController
  before_action :require_user
  
  def index
    @user_requests = current_user.requests
    @friend_requests = current_user.friend_requests
  end
  
end