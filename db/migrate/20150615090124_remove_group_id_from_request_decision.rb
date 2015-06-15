class RemoveGroupIdFromRequestDecision < ActiveRecord::Migration
  def change
    remove_column :request_decisions, :group_id
  end
end
