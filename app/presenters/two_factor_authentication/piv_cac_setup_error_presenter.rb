module TwoFactorAuthentication
  class PivCacSetupErrorPresenter < TwoFactorAuthentication::SetupErrorPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    def title
      t("titles.piv_cac_setup.#{error}")
    end

    def header
      t("headings.piv_cac_setup.#{error}")
    end

    def description
      t("forms.piv_cac_setup.#{error}_html")
    end

    def piv_cac_capture_text
      t('forms.piv_cac_setup.submit')
    end

    def piv_cac_service_link
      redirect_to_piv_cac_service_url
    end

    # TODO: translate from ActiveModel style errors
    def error
      form&.error_type
    end

    def may_select_another_certificate?
      error&.start_with?('certificate.') && error != 'certificate.none' ||
        error == 'token.invalid' || error == 'piv_cac.already_associated'
    end
  end
end
