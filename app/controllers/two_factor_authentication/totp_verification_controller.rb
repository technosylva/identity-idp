module TwoFactorAuthentication
  class TotpVerificationController < ApplicationController
    include TwoFactorAuthenticatable

    before_action :confirm_totp_enabled

    def show
      @presenter = presenter_for_two_factor_authentication_method
    end

    def create
      result = TotpVerificationForm.new(user: current_user, code: params[:code].strip).submit

      analytics.track_event(Analytics::MULTI_FACTOR_AUTH, result.to_h)

      if result.success?
        handle_valid_otp
      else
        handle_invalid_otp
      end
    end

    private

    def configuration_manager
      @configuration_manager ||=
        TwoFactorAuthentication::TotpConfigurationManager.new(current_user)
    end

    def presenter_for_two_factor_authentication_method
      TwoFactorAuthentication::TotpVerifyPresenter.new(configuration_manger, view_context)
    end

    def confirm_totp_enabled
      redirect_to user_two_factor_authentication_url unless configuration_manager.enabled?
    end
  end
end
