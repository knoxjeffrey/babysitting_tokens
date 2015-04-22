class AddPasswordTokenColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_token, :string
  end
end
