class ChangeUserIdInGroupsToAdminId < ActiveRecord::Migration
  def change
    rename_column :groups, :user_id, :admin_id
  end
end
