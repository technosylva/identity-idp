module TwoFactorAuthentication
  class VoiceConfigurationManager < TwoFactorAuthentication::PhoneConfigurationManager
    def available?
      !PhoneNumberCapabilities.new(unconfirmed_phone || user.phone).sms_only?
    end

    ###
    ### Method-specific data management
    ###
    def preferred=(bool)
      user.otp_deliver_preference = if bool
        :voice
      else
        :sms
      end
      user.save
    end
  end
end
