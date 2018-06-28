module TwoFactorAuthentication
  class TotpVerificationForm < TwoFactorAuthentication::VerifyForm
    attr_accessor :code

    def submit
      FormResponse.new(success: valid_totp_code?, errors: {}, extra: extra_analytics_attributes)
    end

    private

    attr_reader :user, :code

    def valid_totp_code?
      configuration_manager.authenticate_totp(code) if code.match? pattern_matching_totp_code_format
    end

    def pattern_matching_totp_code_format
      /\A\d{#{totp_code_length}}\Z/
    end

    def totp_code_length
      Devise.otp_length
    end
  end
end
