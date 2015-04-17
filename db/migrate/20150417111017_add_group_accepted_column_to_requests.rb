class AddGroupAcceptedColumnToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :group_id, :integer
  end
end
