class WorkspacesController < ApplicationController
  before_action :set_workspace, only: %i[show edit update destroy]

  def index
    @workspaces = current_user.workspaces.order(:name)
  end

  def show
    @boards = @workspace.boards.active.order(:name)
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
    @workspace.destroy!
    redirect_to root_path, notice: t("flash.workspace_deleted")
  end

  private

  def set_workspace
    @workspace = current_user.workspaces.find(params[:id])
  end

  def workspace_params
    params.require(:workspace).permit(:name, :description)
  end
end
