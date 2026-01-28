class AddCandidateIdToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :post, :candidate_id, :integer
  end

  def down
    drop_column :post, :candidate_id
  end
end
