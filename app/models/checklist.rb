class Checklist < ApplicationRecord
  belongs_to :card
  has_many :checklist_items, -> { order(:position) }, dependent: :destroy

  acts_as_list scope: :card, column: :position

  validates :title, presence: true

  def progress
    total = checklist_items.size
    return [ 0, 0 ] if total.zero?
    [ checklist_items.count(&:completed?), total ]
  end
end
