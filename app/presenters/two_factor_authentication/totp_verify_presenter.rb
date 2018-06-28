module TwoFactorAuthentication
  class TotpVerifyPresenter < VerifyPresenter
    def title
      t('titles.enter_2fa_code')
    end

    def header
      t('devise.two_factor_authentication.totp_header_text')
    end

    def help_text
      t("instructions.mfa.totp.confirm_code_html",
        email: content_tag(:strong, user.email),
        app: content_tag(:strong, APP_NAME),
        tooltip: view.tooltip(t('tooltips.authentication_app')))
    end
  end
end
