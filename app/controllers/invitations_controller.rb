class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_invitation

  def show
    if @invitation.expired?
      redirect_to root_path, alert: t("flash.invitation_expired")
    elsif @invitation.accepted?
      redirect_to(user_signed_in? ? @invitation.board : new_user_session_path,
                  notice: t("flash.already_joined"))
    end
  end

  def accept
    unless user_signed_in?
      store_location_for(:user, invitation_path(@invitation))
      redirect_to new_user_session_path
      return
    end

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
