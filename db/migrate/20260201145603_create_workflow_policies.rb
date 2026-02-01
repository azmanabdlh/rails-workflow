class CreateWorkflowPolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :workflow_policies do |t|
      t.jsonb :quorum
      t.references :workflow, null: false, foreign_key: true
      t.boolean :active
      t.integer :action_phase

      t.timestamps
    end
  end
end
