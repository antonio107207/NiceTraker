class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.datetime :due_date
      t.boolean :due_completed
      t.string :cover_color
      t.references :list, null: false, foreign_key: true
      t.references :board, null: false, foreign_key: true
      t.datetime :archived_at

      t.timestamps
    end
  end
end
