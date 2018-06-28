module TwoFactorAuthentication
  class TotpSelectionPresenter < SelectionPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    def link
      view.link_to(
        t('links.two_factor_authentication.app'),
        login_two_factor_authenticator_path(locale: LinkLocaleResolver.locale)
      )
    end

    def option
      safe_join([link, '.'])
    end
  end
end
