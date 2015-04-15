class RemoveTokensFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :tokens
  end
end
