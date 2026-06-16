class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :card, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :minutes
      t.string :description
      t.datetime :logged_at

      t.timestamps
    end
  end
end
