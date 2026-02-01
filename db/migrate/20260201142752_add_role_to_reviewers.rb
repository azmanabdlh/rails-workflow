class AddRoleToReviewers < ActiveRecord::Migration[8.0]
  def change
    add_column :reviewers, :role, :integer, default: 1, null: false
  end

  def down
    drop_column :reviewers, :role
  end
end
