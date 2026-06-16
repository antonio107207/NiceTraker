class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :trackable, polymorphic: true, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :key
      t.jsonb :parameters
      t.references :board, null: false, foreign_key: true

      t.timestamps
    end
  end
end
