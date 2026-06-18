class ChecklistItem < ApplicationRecord
  belongs_to :checklist
  belongs_to :assignee, class_name: "User", optional: true

  acts_as_list scope: :checklist, column: :position

  validates :title, presence: true

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :accessible_to, ->(user) { joins(checklist: { card: :board }).where(boards: { id: user.boards.select(:id) }) }

  def completed?
    completed == true
  end
end
