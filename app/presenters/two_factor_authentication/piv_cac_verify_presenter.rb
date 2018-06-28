module TwoFactorAuthentication
  class PivCacVerifyPresenter < VerifyPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    def title
      t('titles.present_piv_cac')
    end

    def header
      t('devise.two_factor_authentication.piv_cac_header_text')
    end

    def help_text
      t('instructions.mfa.piv_cac.confirm_piv_cac_html',
        email: content_tag(:strong, user_email),
        app: content_tag(:strong, APP_NAME))
    end

    def piv_cac_capture_text
      t('forms.piv_cac_mfa.submit')
    end

    def piv_cac_service_link
      redirect_to_piv_cac_service_url
    end
  end
end
