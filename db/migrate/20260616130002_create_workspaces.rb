class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.boolean :personal, default: false, null: false

      t.timestamps
    end
  end
end
