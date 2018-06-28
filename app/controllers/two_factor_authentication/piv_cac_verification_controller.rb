module TwoFactorAuthentication
  class PivCacVerificationController < ApplicationController
    include TwoFactorAuthenticatable
    include PivCacConcern

    before_action :confirm_piv_cac_enabled, only: :show
    before_action :reset_attempt_count_if_user_no_longer_locked_out, only: :show

    def show
      if params[:token]
        process_token
      else
        @presenter = configuration_manager.verify_presenter(view_context)
      end
    end

    private

    def process_token
      result = piv_cac_verfication_form.submit
      analytics.track_event(Analytics::MULTI_FACTOR_AUTH, result.to_h.merge(analytics_properties))
      if result.success?
        handle_valid_piv_cac
      else
        handle_invalid_piv_cac
      end
    end

    def handle_valid_piv_cac
      clear_piv_cac_nonce
      save_piv_cac_information(
        subject: piv_cac_verfication_form.x509_dn,
        presented: true
      )

      handle_valid_otp_for_authentication_context
      redirect_to next_step
      reset_otp_session_data
    end

    def next_step
      return account_recovery_setup_url unless backup_2fa_configured?

      after_otp_verification_confirmation_url
    end

    def handle_invalid_piv_cac
      clear_piv_cac_information
      handle_invalid_otp(type: 'piv_cac')
    end

    def piv_cac_view_data
      {
        two_factor_authentication_method: two_factor_authentication_method,
        user_email: current_user.email,
        remember_device_available: false,
        totp_enabled: current_user.totp_enabled?,
        phone_enabled: current_user.phone_enabled?,
        piv_cac_nonce: piv_cac_nonce,
      }.merge(generic_data)
    end

    def piv_cac_verfication_form
      @piv_cac_verification_form ||= # UserPivCacVerificationForm.new(
        # user: current_user,
      configuration_manager.verify_form(
        token: params[:token],
        nonce: piv_cac_nonce
      )
    end

    def confirm_piv_cac_enabled
      redirect_to user_two_factor_authentication_url unless configuration_manager.enabled?
    end

    def presenter_for_two_factor_authentication_method
      configuration_manager.verify_presenter(view_context)
      # TwoFactorAuthCode::PivCacAuthenticationPresenter.new(
      #   view: view_context,
      #   data: piv_cac_view_data
      # )
    end

    def analytics_properties
      {
        context: context,
        multi_factor_auth_method: 'piv_cac',
      }
    end

    def method_manager
      @method_manager = TwoFactorAuthentication::MethodManager.new(current_user)
    end

    def configuration_manager
      @configuration_manager = method_manager.configuration_manager(:piv_cac)
    end

    # ultimately, we want to do account recovery setup if the user has only the piv/cac
    # configured. Don't count remember device or personal key since personal key will come
    # after anyways.
    def backup_2fa_configured?
      %i[sms voice].any? do |method|
        method_manager.configuration_manager(method).enabled?
      end
    end
  end
end
