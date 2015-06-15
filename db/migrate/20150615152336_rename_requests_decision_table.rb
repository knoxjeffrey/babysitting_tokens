class RenameRequestsDecisionTable < ActiveRecord::Migration
  def change
    rename_table :request_decisions, :declined_requests
  end
end
