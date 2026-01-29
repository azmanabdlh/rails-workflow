class AddIsEndedToStages < ActiveRecord::Migration[8.0]
  def change
    add_column :stages, :is_ended, :boolean, default: false
  end

  def down
    drop_column :stages, :is_ended
  end
end
