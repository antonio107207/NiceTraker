class AddTimeTrackingToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :estimated_minutes, :integer
  end
end
