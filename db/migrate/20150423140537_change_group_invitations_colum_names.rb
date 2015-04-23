class ChangeGroupInvitationsColumNames < ActiveRecord::Migration
  def change
    rename_column :group_invitations, :recipient_name, :friend_name
    rename_column :group_invitations, :recipient_email_address, :friend_email
  end
end
