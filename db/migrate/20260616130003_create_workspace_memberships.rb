class CreateWorkspaceMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :workspace_memberships do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 1, null: false

      t.timestamps
    end

    add_index :workspace_memberships, %i[workspace_id user_id], unique: true
  end
end
