class Portal::UsersController < Portal::BaseController
  before_action :set_user, only: %i[show edit update destroy toggle_super_admin]

  def index
    @users = User.order(created_at: :desc)
    @users = @users.where("name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @workspace_memberships = @user.workspace_memberships.includes(:workspace)
    @board_memberships     = @user.board_memberships.includes(:board)
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to portal_user_path(@user), notice: t("portal.users.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to portal_users_path, alert: t("portal.users.cannot_delete_self") and return if @user == current_user

    @user.destroy!
    redirect_to portal_users_path, notice: t("portal.users.deleted")
  end

  def toggle_super_admin
    redirect_to portal_users_path, alert: t("portal.users.cannot_demote_self") and return if @user == current_user

    @user.update!(super_admin: !@user.super_admin?)
    redirect_back fallback_location: portal_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
