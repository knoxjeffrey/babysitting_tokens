class CreatesGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :circle_name, :location
      t.integer :user_id
      
      t.timestamps
    end
  end
end
