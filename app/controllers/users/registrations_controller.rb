# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    def new
      build_resource
      resource.build_person
      respond_with resource
    end

    # rubocop:disable Metrics/AbcSize
    # POST /resource
    def create
      email = sign_up_params['person_attributes']['email']
      build_resource(sign_up_params.merge(email: email))

      person = Person.find_by(email: email)
      if person.present?
        person.skip_person_validation = true
        person.assign_attributes(sign_up_params['person_attributes'])
        resource.person = person
      end

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
    # rubocop:enable Metrics/AbcSize

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    def after_inactive_sign_up_path_for(_resource)
      new_user_confirmation_path
    end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [person_attributes: %i[firstname lastname email]])
    end

    # def person_params
    #   params.permit(:firstname, :lastname)
    # end

    # def user_params
    #   params.require(:user).permit(:email, :password, :password_confirmation)
    # end
  end
end
