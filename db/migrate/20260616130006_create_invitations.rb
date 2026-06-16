class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :board, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.string :email
      t.string :token, null: false
      t.integer :role, default: 1, null: false
      t.integer :status, default: 0, null: false
      t.datetime :expires_at

      t.timestamps
    end
  end
end
