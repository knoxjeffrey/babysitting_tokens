class AddTokenColumnToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :tokens, :integer, default: 20
  end
end
