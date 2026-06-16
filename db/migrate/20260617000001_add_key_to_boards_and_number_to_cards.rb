class AddKeyToBoardsAndNumberToCards < ActiveRecord::Migration[8.1]
  def up
    add_column :boards, :key, :string, limit: 6, null: false, default: "" unless column_exists?(:boards, :key)
    add_column :cards, :number, :integer unless column_exists?(:cards, :number)

    # Ruby backfill: generate unique keys per workspace
    Board.reset_column_information
    Board.all.group_by(&:workspace_id).each do |_workspace_id, boards|
      used = {}
      boards.sort_by(&:id).each do |board|
        base = board.name.gsub(/[^A-Za-z0-9]/, "").upcase.first(5).presence || "BRD"
        key = base
        n = 2
        while used[key]
          key = "#{base.first(4)}#{n}"
          n += 1
        end
        used[key] = true
        board.update_columns(key: key)
      end
    end

    # Backfill card numbers per board
    Card.reset_column_information
    Card.all.group_by(&:board_id).each do |_board_id, cards|
      cards.sort_by(&:id).each_with_index do |card, i|
        card.update_columns(number: i + 1)
      end
    end

    add_index :boards, %i[workspace_id key], unique: true unless index_exists?(:boards, %i[workspace_id key])
    add_index :cards, %i[board_id number], unique: true unless index_exists?(:cards, %i[board_id number])
  end

  def down
    remove_index :boards, %i[workspace_id key] if index_exists?(:boards, %i[workspace_id key])
    remove_index :cards, %i[board_id number] if index_exists?(:cards, %i[board_id number])
    remove_column :boards, :key if column_exists?(:boards, :key)
    remove_column :cards, :number if column_exists?(:cards, :number)
  end
end
