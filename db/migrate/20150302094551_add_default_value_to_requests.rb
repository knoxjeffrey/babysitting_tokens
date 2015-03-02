class AddDefaultValueToRequests < ActiveRecord::Migration
  def change
    change_column :requests, :status, :string, default: 'waiting'
  end
end
