class RemoveDecisionFromDeclinedRequests < ActiveRecord::Migration
  def change
    remove_column :declined_requests, :decision
  end
end
