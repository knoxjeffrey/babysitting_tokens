class CreateRequestDecisions < ActiveRecord::Migration
  def change
    create_table :request_decisions do |t|
      t.integer :request_id, :group_id, :user_id
      t.string :decision
      
      t.timestamps
    end
  end
end
