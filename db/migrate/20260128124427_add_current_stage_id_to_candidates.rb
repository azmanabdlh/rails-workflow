class AddCurrentStageIdToCandidates < ActiveRecord::Migration[8.0]
  def change
    add_column :candidates, :current_stage_id, :integer
  end

  def down
    drop_column :candidates, :current_stage_id
  end
end
