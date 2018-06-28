module TwoFactorAuthentication
  class PivCacSetupPresenter < SetupPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    def title
      t('titles.piv_cac_setup.new')
    end

    def header
      t('headings.piv_cac_setup.new')
    end

    def description
      t('forms.piv_cac_setup.piv_cac_intro_html')
    end

    def piv_cac_capture_text
      t('forms.piv_cac_setup.submit')
    end

    def piv_cac_service_link
      redirect_to_piv_cac_service_url
    end
  end
end
