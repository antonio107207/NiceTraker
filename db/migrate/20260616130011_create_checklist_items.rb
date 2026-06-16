class CreateChecklistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :checklist_items do |t|
      t.string :title
      t.integer :position
      t.boolean :completed, default: false, null: false
      t.references :checklist, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.datetime :due_date

      t.timestamps
    end
  end
end
