class WorkspaceMembershipsController < ApplicationController
  before_action :set_membership

  def destroy
    authorize @workspace, :remove_member?
    @removed_user = @membership.user
    @membership.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to workspace_path(@workspace), notice: t("flash.member_removed") }
    end
  end

  private

  def set_membership
    @membership = WorkspaceMembership.find(params[:id])
    @workspace = @membership.workspace
  end
end
