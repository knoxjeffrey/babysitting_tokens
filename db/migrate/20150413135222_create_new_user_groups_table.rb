class CreateNewUserGroupsTable < ActiveRecord::Migration
  def change
    create_table :new_user_groups_tables do |t|
      t.integer :user_id, :group_id
      
      t.timestamps
    end
  end
end
