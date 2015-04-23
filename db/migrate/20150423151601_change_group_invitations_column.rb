class ChangeGroupInvitationsColumn < ActiveRecord::Migration
  def change
    rename_column :group_invitations, :token, :identifier
  end
end
