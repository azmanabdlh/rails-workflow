class CreateCandidateStages < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_stages do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :stage, null: false, foreign_key: true
      t.date :entered_at
      t.date :exited_at

      t.timestamps
    end
  end

  def down
    drop_table :candidate_stages
  end
end
