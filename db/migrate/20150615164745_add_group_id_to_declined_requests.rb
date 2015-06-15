class AddGroupIdToDeclinedRequests < ActiveRecord::Migration
  def change
    add_column :declined_requests, :group_id, :integer
  end
end
