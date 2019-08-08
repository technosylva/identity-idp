module TwoFactorAuthentication
  class SmsSelectionPresenter < PhoneSelectionPresenter
    def method
      :sms
    end

    def recommended?
      false
    end
  end
end
