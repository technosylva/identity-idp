module TwoFactorAuthentication
  class SmsSelectionPresenter < PhoneSelectionPresenter
    def method
      :sms
    end

    def font_color
      'blue'
    end

    def bg_color
      'bg-lightest-blue'
    end

    def border_color
      ''
    end

    def recommended?
      false
    end
  end
end
