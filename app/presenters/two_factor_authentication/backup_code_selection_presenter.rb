module TwoFactorAuthentication
  class BackupCodeSelectionPresenter < SelectionPresenter
    # :reek:BooleanParameter
    def initialize(only = false)
      @only_backup_codes = only
    end

    def method
      if @only_backup_codes
        :backup_code_only
      else
        :backup_code
      end
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

    private

    attr_reader :only_backup_codes
  end
end
