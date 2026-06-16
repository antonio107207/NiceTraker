class CreateCardRelations < ActiveRecord::Migration[8.1]
  def change
    create_table :card_relations do |t|
      t.references :card,         null: false, foreign_key: true
      t.references :related_card, null: false, foreign_key: { to_table: :cards }
      t.string :relation_type, null: false, default: "relates_to"
      t.timestamps
    end

    add_index :card_relations,
              %i[card_id related_card_id relation_type],
              unique: true,
              name: "idx_unique_card_relation"
  end
end
