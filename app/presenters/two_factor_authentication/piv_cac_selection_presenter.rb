module TwoFactorAuthentication
  class PivCacSelectionPresenter < SelectionPresenter
    def method
      :piv_cac
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
      true
    end
  end
end
