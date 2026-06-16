class InvitationsController < ApplicationController
  before_action :set_invitation

  def show
    if @invitation.expired?
      redirect_to root_path, alert: t("flash.invitation_expired")
    elsif @invitation.accepted?
      redirect_to @invitation.board, notice: t("flash.already_joined")
    end
  end

  def accept
    if @invitation.accept!(current_user)
      redirect_to board_path(@invitation.board),
                  notice: t("flash.invitation_welcome", board: @invitation.board.name)
    else
      redirect_to root_path, alert: t("flash.invitation_failed")
    end
  end

  def decline
    @invitation.declined!
    redirect_to root_path, notice: t("flash.invitation_declined")
  end

  private

  def set_invitation
    @invitation = Invitation.find_by!(token: params[:token] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t("flash.invitation_invalid")
  end
end
