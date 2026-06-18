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
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many_attached :attachments
  has_rich_text :description

  acts_as_list scope: :list, column: :position

  validates :title, presence: true

  attr_accessor :updated_by

  before_create :assign_number

  NOTIFIABLE_CHANGES = %w[title description due_date due_completed cover_color].freeze

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
  scope :accessible_to, ->(user) { joins(:board).where(boards: { id: user.boards.select(:id) }) }

  after_create_commit  :broadcast_card_create
  after_update_commit  :broadcast_card_update
  after_update_commit  :notify_members_of_update
  after_update_commit  :log_activity
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
    return [ 0, 0 ] if total.zero?
    [ done, total ]
  end

  def notify_assignment!(user, actor, action)
    Notification.create!(
      recipient:   user,
      actor:       actor,
      notifiable:  self,
      action_type: action
    )
  end

  private

  def assign_number
    return if number.present?
    board_id_val = board_id || board.id
    # pg_advisory_xact_lock holds until the whole transaction commits (including INSERT),
    # unlike board.with_lock which releases at savepoint — preventing the race condition.
    self.class.connection.execute(
      "SELECT pg_advisory_xact_lock(1, #{board_id_val.to_i})"
    )
    self.number = (self.class.where(board_id: board_id_val).maximum(:number) || 0) + 1
  end

  def notify_members_of_update
    return unless updated_by
    return if (saved_changes.keys & NOTIFIABLE_CHANGES).empty?

    members.where.not(id: updated_by.id).each do |member|
      Notification.create!(
        recipient:   member,
        actor:       updated_by,
        notifiable:  self,
        action_type: :card_updated
      )
    end
  end

  ACTIVITY_FIELDS = {
    "title"        => ->(old, _new) { { key: "card.title_changed", params: { from: old } } },
    "due_date"     => ->(_old, new_val) { { key: new_val.present? ? "card.due_date_set" : "card.due_date_cleared", params: {} } },
    "due_completed" => ->(_old, new_val) { { key: new_val ? "card.completed" : "card.reopened", params: {} } },
    "list_id"      => ->(_old, new_val) { { key: "card.moved", params: { to: List.find_by(id: new_val)&.name.to_s } } },
    "archived_at"  => ->(_old, new_val) { { key: new_val.present? ? "card.archived" : "card.unarchived", params: {} } }
  }.freeze

  def log_activity
    return unless updated_by

    ACTIVITY_FIELDS.each do |field, builder|
      next unless saved_changes.key?(field)
      old_val, new_val = saved_changes[field]
      result = builder.call(old_val, new_val)
      Activity.log(key: result[:key], owner: updated_by, board: board, trackable: self, params: result[:params])
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
