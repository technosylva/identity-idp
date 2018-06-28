module TwoFactorAuthentication
  class PhoneConfigurationManager < ConfigurationManager
    def enabled?
      user.phone_enabled? && available?
    end

    def configured?
      user.phone_enabled? && available?
    end

    ###
    ### Method-specific data management
    ###
    def phone
      user.phone
    end

    def preferred?
      user.otp_delivery_preference == method
    end

    def unconfirmed_phone

    end

    def save_configuration
    end

    def confirm_configuration
    end

    def remove_configuration
    end
  end
end
