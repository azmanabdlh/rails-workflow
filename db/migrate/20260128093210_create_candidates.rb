class CreateCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def down
    drop_table :candidates
  end
end
