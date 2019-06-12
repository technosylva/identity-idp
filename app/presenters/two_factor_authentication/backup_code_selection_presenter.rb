module TwoFactorAuthentication
  class BackupCodeSelectionPresenter < SelectionPresenter
    def method
      :backup_code
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
