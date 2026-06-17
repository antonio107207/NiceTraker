module Users
  class RegistrationsController < Devise::RegistrationsController
    private

    def update_resource(resource, params)
      if params[:password].blank?
        params.delete(:current_password)
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end
  end
end
