class AddColumnToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :babysitter_id, :integer
  end
end
