class Card < ApplicationRecord
  belongs_to :list
  belongs_to :board
  has_many :card_memberships, dependent: :destroy
  has_many :members, through: :card_memberships, source: :user
  has_many :card_labels, dependent: :destroy
  has_many :labels, through: :card_labels
  has_many :checklists, -> { order(:position) }, dependent: :destroy
  has_many :comments, -> { order(:created_at) }, dependent: :destroy
  has_many :time_entries,   -> { order(logged_at: :desc) }, dependent: :destroy
  has_many :card_relations, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy
  has_many_attached :attachments
  has_rich_text :description

  acts_as_list scope: :list, column: :position

  validates :title, presence: true

  before_create :assign_number

  def identifier
    "#{board.key}-#{number}"
  end

  def total_logged_minutes
    time_entries.sum(:minutes)
  end

  def formatted_time(minutes)
    return nil if minutes.nil? || minutes.zero?
    h, m = minutes.divmod(60)
    return "#{h}h #{m}m" if h > 0 && m > 0
    return "#{h}h"       if h > 0
    "#{m}m"
  end

  scope :active, -> { where(archived_at: nil) }
  scope :due_soon, -> { where("due_date <= ? AND due_completed = false", 2.days.from_now) }
  scope :overdue, -> { where("due_date < ? AND due_completed = false", Time.current) }

  after_create_commit  :broadcast_card_create
  after_update_commit  :broadcast_card_update
  after_destroy_commit :broadcast_card_remove

  def move_to_list!(new_list, new_position = nil)
    self.list  = new_list
    self.board = new_list.board
    # save! fires acts_as_list's before_update :check_scope which adjusts positions
    # in the old list; record has no dirty attrs after save so insert_at's with_lock works
    save!
    if new_position
      insert_at(new_position.to_i)
    else
      move_to_bottom
    end
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def checklist_progress
    items = checklists.joins(:checklist_items).includes(:checklist_items)
    total = items.sum { |c| c.checklist_items.size }
    done  = items.sum { |c| c.checklist_items.count(&:completed?) }
    return [0, 0] if total.zero?
    [ done, total ]
  end

  private

  def assign_number
    return if number.present?
    board.with_lock do
      self.number = (board.cards.maximum(:number) || 0) + 1
    end
  end

  def broadcast_card_create
    broadcast_append_to board,
      target: "cards_list_#{list_id}",
      partial: "cards/card",
      locals:  { card: self }
  end

  def broadcast_card_update
    # Don't broadcast if only position changed (sortable handles that client-side)
    return if saved_changes.keys == %w[position updated_at]
    return if saved_change_to_archived_at? && archived_at.present?

    broadcast_replace_to board,
      target: "card_#{id}",
      partial: "cards/card",
      locals:  { card: self }
  end

  def broadcast_card_remove
    broadcast_remove_to board, target: "card_#{id}"
  end
end
