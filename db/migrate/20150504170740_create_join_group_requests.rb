class CreateJoinGroupRequests < ActiveRecord::Migration
  def change
    create_table :join_group_requests do |t|
      t.integer :requester_id, :group_member_id, :group_id
      t.string :identifier
      
      t.timestamps
    end
  end
end
