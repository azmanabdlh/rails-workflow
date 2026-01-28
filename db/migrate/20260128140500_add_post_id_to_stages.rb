class AddPostIdToStages < ActiveRecord::Migration[8.0]
  def change
    add_reference :stages, :post, null: false, foreign_key: true
  end

  def down
    drop_column :stages, :post
  end
end
