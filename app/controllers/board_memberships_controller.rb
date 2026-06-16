class BoardMembershipsController < ApplicationController
  before_action :set_membership

  def destroy
    authorize @board, :remove_member?
    @removed_user = @membership.user
    @membership.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to board_path(@board), notice: t("flash.member_removed") }
    end
  end

  private

  def set_membership
    @membership = BoardMembership.find(params[:id])
    @board = @membership.board
  end
end
