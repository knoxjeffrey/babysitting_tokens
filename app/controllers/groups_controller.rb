class GroupsController < ApplicationController
  before_action :require_user
  
  def new
    @group = Group.new
  end
  
  def create
    @group = current_user.groups.build(request_params)
  
    if @group.save
      flash[:success] = "You successfully created your request for freedom!"
      redirect_to home_path
    else
      render :new
    end
  end
  
  private
  
  def request_params
    params.require(:group).permit(:group_name, :location)
  end
  
end