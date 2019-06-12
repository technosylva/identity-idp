module TwoFactorAuthentication
  class WebauthnSelectionPresenter < SelectionPresenter
    def method
      :webauthn
    end

    def html_class
      'hide'
    end

    def font_color
      'green-dark'
    end

    def bg_color
      'bg-light-green'
    end

    def border_color
      '-green'
    end
  end
end
