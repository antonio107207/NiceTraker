class CreateChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :checklists do |t|
      t.string :title
      t.integer :position
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
