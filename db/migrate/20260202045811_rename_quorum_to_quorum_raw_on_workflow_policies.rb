class RenameQuorumToQuorumRawOnWorkflowPolicies < ActiveRecord::Migration[8.0]
  def change
    rename_column :workflow_policies, :quorum, :quorum_raw
  end

  def down
    rename_column :workflow_policies, :quorum_raw, :quorum
  end
end
