class CreateBoardMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :board_memberships do |t|
      t.references :board, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 1, null: false

      t.timestamps
    end

    add_index :board_memberships, %i[board_id user_id], unique: true
  end
end
