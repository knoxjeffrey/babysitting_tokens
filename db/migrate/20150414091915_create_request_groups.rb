class CreateRequestGroups < ActiveRecord::Migration
  def change
    create_table :request_groups do |t|
      t.integer :request_id, :group_id
      
      t.timestamps
    end
  end
end
