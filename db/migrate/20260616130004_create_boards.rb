class CreateBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :boards do |t|
      t.string :name
      t.string :background_color
      t.integer :visibility
      t.references :workspace, null: false, foreign_key: true
      t.datetime :archived_at

      t.timestamps
    end
  end
end
