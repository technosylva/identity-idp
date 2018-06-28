module TwoFactorAuthentication
  class SmsConfigurationManager < TwoFactorAuthentication::PhoneConfigurationManager
    def available?
      # TODO: check if the phone number disallows SMS
      #   - because Twilio doesn't support SMS to that number, OR
      #   - because the owner of the phone number has texted 'STOP' to us
      # PhoneNumberCapabilities.new(user.phone).sms_only?
      true
    end
    ###
    ### Method-specific data management
    ###
    def preferred?
      user.otp_delivery_preference == :sms
    end

    def preferred=(bool)
      user.otp_deliver_preference = if bool
        :sms
      else
        :voice
      end
      user.save
    end
  end
end
