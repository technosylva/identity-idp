module TwoFactorAuthentication
  class SelectionPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::UrlHelper

    attr_reader :configuration

    def initialize(configuration = nil)
      @configuration = configuration
    end

    def type
      method.to_s
    end

    def label
      t("two_factor_authentication.#{option_mode}.#{method}")
    end

    def info
      t("two_factor_authentication.#{option_mode}.#{method}_info")
    end

    def more_info
      t("two_factor_authentication.#{option_mode}.#{method}_more_info")
    end

    def html_class
      ''
    end

    def learn_more?
      (type == "webauthn" || type == "auth_app") && option_mode.to_s == "two_factor_choice_options"
    end

    def learn_more_path
      type == "webauthn" ? webauthn_learn_more_path : auth_app_learn_more_path
    end

    private

    def option_mode
      if @configuration.present?
        'login_options'
      else
        'two_factor_choice_options'
      end
    end

    def auth_app_learn_more_path
      'https://login.gov/help/signing-in/what-is-an-authentication-app/'
    end

    def webauthn_learn_more_path
      'https://login.gov/help/security-keys/what-is-a-security-key/'
    end
  end
end
