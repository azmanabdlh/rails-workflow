class CreateWorkflows < ActiveRecord::Migration[8.0]
  def change
    create_table :workflows do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :stage, null: false, foreign_key: true
      t.datetime :entered_at
      t.datetime :exited_at

      t.timestamps
    end
  end

  def down
    drop_table :workflows
  end
end
