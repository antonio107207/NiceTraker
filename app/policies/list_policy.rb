class ListPolicy < ApplicationPolicy
  delegate :show?, :create?, :edit?, :update?, :destroy?, to: :board_policy

  def move? = board_policy.manage_lists?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end

  private

  def board_policy
    @board_policy ||= BoardPolicy.new(user, record.board)
  end
end
