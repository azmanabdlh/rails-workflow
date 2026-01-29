class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.date :started_at
      t.date :ended_at

      t.timestamps
    end
  end

  def down
    drop_table :posts
  end
end
