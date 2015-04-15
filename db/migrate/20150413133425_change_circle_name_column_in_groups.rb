class ChangeCircleNameColumnInGroups < ActiveRecord::Migration
  def change
    rename_column :groups, :circle_name, :group_name
  end
end
