class CreateReviewers < ActiveRecord::Migration[8.0]
  def change
    create_table :reviewers do |t|
      t.references :workflow, null: false, foreign_key: true
      t.integer :phase
      t.date :decided_at
      t.text :feedback
      t.integer :order
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
