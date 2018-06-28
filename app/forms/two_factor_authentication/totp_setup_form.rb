module TwoFactorAuthentication
  class TotpSetupForm < TwoFactorAuthentication::SetupForm
    attr_accessor :secret, :code

    def submit
      @success = valid_totp_code?

      process_valid_submission if success

      FormResponse.new(success: success, errors: {})
    end

    private

    attr_reader :user, :code, :secret, :success

    def valid_totp_code?
      configuration_manager.confirm_secret(secret, code)
    end

    def process_valid_submission
      configuration_manager.save_configuration
    end
  end
end
