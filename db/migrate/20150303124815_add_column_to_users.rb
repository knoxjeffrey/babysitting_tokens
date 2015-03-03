class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tokens, :integer, default: 20
  end
end
