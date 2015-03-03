class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.datetime :start
      t.datetime :finish
      t.string :status
      
      t.timestamps
    end
  end
end
