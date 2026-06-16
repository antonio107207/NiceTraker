class List < ApplicationRecord
  belongs_to :board
  has_many :cards, -> { where(archived_at: nil).order(:position) }, dependent: :destroy
  has_many :all_cards, class_name: "Card", dependent: :destroy

  acts_as_list scope: :board, column: :position

  validates :name, presence: true

  scope :active, -> { where(archived_at: nil) }

  after_create_commit  :broadcast_list_create
  after_update_commit  :broadcast_list_update
  after_destroy_commit :broadcast_list_remove

  def archive!
    update!(archived_at: Time.current)
  end

  private

  def broadcast_list_create
    broadcast_append_to board,
      target: "lists_container",
      partial: "lists/list",
      locals:  { list: self, board: board }
  end

  def broadcast_list_update
    return if saved_changes.keys == %w[position updated_at]

    broadcast_replace_to board,
      target: "list_#{id}",
      partial: "lists/list",
      locals:  { list: self, board: board }
  end

  def broadcast_list_remove
    broadcast_remove_to board, target: "list_#{id}"
  end
end
