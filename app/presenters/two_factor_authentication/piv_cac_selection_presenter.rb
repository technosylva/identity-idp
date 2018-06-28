module TwoFactorAuthentication
  class PivCacSelectionPresenter < SelectionPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    def link
      view.link_to(
        t('devise.two_factor_authentication.piv_cac_fallback.link'),
        login_two_factor_piv_cac_path(locale: LinkLocaleResolver.locale)
      )
    end

    def option
      t(
        'devise.two_factor_authentication.piv_cac_fallback.text_html',
        link: link
      )
    end
  end
end
