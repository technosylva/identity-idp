module TwoFactorAuthentication
  class SelectionPresenter
    attr_reader :configuration_manager, :view

    def initialize(configuration_manager, view)
      @configuration_manager = configuration_manager
      @view = view
    end

    def label
      t("devise.two_factor_authentication.two_factor_choice_options.#{method}")
    end

    def info
      t("devise.two_factor_authentication.two_factor_choice_options.#{method}_info")
    end

    def configured?
      configuration_manager.configured?
    end

    def configurable?
      configuration_manager.available? && !configured?
    end

    def enabled?
      configuration_manager.enabled?
    end

    def method
      @method ||= begin
        self.class.name.demodulize.sub(/SelectionPresenter$/, '').snakecase.to_sym
      end
    end
  end
end
