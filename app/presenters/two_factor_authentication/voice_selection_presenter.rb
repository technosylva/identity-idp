module TwoFactorAuthentication
  class VoiceSelectionPresenter < PhoneSelectionPresenter
    def method
      :voice
    end

    def recomended?
      false
    end
  end
end
