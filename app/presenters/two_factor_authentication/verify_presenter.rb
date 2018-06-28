module TwoFactorAuthentication
  class VerifyPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    attr_reader :configuration_manager, :view, :method_manager

    def initialize(configuration_manager, view)
      @configuration_manager = configuration_manager
      @view = view
      @method_manager = TwoFactorAuthentication::MethodManager.new(configuration_manager.user)
    end

    def method
      @method ||= begin
        self.class.name.demodulize.sub(/VerifyPresenter$/, '').snakecase.to_sym
      end
    end

    def fallback_options
      method_manager.enabled_selection_presenters(view).reject do |presenter|
        presenter.method == method
      end
    end

    def cancel_link
      locale = LinkLocaleResolver.locale
      if reauthn
        account_path(locale: locale)
      else
        sign_out_path(locale: locale)
      end
    end
  end
end
