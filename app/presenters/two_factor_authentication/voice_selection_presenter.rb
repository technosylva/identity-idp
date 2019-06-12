module TwoFactorAuthentication
  class VoiceSelectionPresenter < PhoneSelectionPresenter
    def method
      :voice
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
  end
end
