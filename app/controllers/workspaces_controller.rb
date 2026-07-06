class WorkspacesController < ApplicationController
  before_action :set_workspace,        only: %i[show edit update destroy archive]
  before_action :redirect_if_archived, only: %i[show edit update]

  def index
    @workspaces          = current_user.workspaces.active.order(:name)
    @archived_workspaces = current_user.workspaces.archived.order(archived_at: :desc)
  end

  def show
    authorize @workspace
    @boards          = @workspace.boards.active.order(:name)
    @archived_boards = @workspace.boards.where.not(archived_at: nil).order(archived_at: :desc)
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.owner = current_user

    if @workspace.save
      @workspace.workspace_memberships.create!(user: current_user, role: :admin)
      redirect_to @workspace, notice: t("flash.workspace_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @workspace.update(workspace_params)
      if turbo_frame_request?
        render turbo_stream: [
          turbo_stream.replace("workspace_header",
            partial: "workspaces/header", locals: { workspace: @workspace }),
          turbo_stream.replace("modal", "")
        ]
      else
        redirect_to @workspace, notice: t("flash.workspace_updated")
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @workspace
    @workspace.destroy!
    redirect_to root_path, notice: t("flash.workspace_deleted")
  end

  def archive
    authorize @workspace
    if @workspace.archived_at.present?
      @workspace.update!(archived_at: nil)
      redirect_to @workspace, notice: t("flash.workspace_unarchived")
    else
      @workspace.update!(archived_at: Time.current)
      redirect_to root_path, notice: t("flash.workspace_archived")
    end
  end

  private

  def set_workspace
    @workspace = current_user.workspaces.find(params[:id])
  end

  def redirect_if_archived
    return unless @workspace.archived_at?

    redirect_to root_path, alert: t("flash.workspace_is_archived")
  end

  def workspace_params
    params.require(:workspace).permit(:name, :description)
  end
end
