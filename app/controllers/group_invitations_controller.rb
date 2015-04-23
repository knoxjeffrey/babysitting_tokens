class GroupInvitationsController < ApplicationController
  
  before_action :require_user
  
  def new
    @invitation = GroupInvitation.new
  end

  def create
  
  end
  
end