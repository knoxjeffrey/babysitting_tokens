class RenameNewUserGroupsTable < ActiveRecord::Migration
  def change
    rename_table :new_user_groups_tables, :user_groups
  end
end
