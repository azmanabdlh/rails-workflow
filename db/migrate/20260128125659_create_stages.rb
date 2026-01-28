class CreateStages < ActiveRecord::Migration[8.0]
  def change
    create_table :stages do |t|
      t.string :name
      t.references :parent,
        null: true,
        foreign_key: { to_table: :stages },
        index: true

      t.integer :order

      t.timestamps
    end
  end

  def down
    drop_table :stages
  end
end
