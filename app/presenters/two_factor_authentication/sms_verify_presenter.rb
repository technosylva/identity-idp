module TwoFactorAuthentication
  class SmsVerifyPresenter < VerifyPresenter
    def title
      t('titles.enter_2fa_code')
    end

    def header
      t('devise.two_factor_authentication.header_text')
    end

    def phone_number_message
      t('instructions.mfa.sms.number_message',
        number: content_tag(:strong, phone_number),
        expiration: Figaro.env.otp_valid_for)
    end

    def help_text
      t('instructions.mfa.sms.confirm_code_html',
        resend_code_link: resend_code_link)
    end

    def cancel_link
      locale = LinkLocaleResolver.locale
      if confirmation_for_phone_change || reauthn
        account_path(locale: locale)
      elsif confirmation_for_idv
        idv_cancel_path(locale: locale)
      else
        sign_out_path(locale: locale)
      end
    end

    private

    attr_reader(
      :totp_enabled,
      :reenter_phone_number_path,
      :phone_number,
      :unconfirmed_phone,
      :otp_delivery_preference,
      :confirmation_for_phone_change,
      :voice_otp_delivery_unsupported,
      :confirmation_for_idv
    )

    def otp_fallback_options
      if totp_enabled
        otp_fallback_options_with_totp
      elsif !voice_otp_delivery_unsupported
        safe_join([phone_fallback_link, '.'])
      end
    end

    def otp_fallback_options_with_totp
      if voice_otp_delivery_unsupported
        safe_join([auth_app_fallback_tag, '.'])
      else
        safe_join([phone_fallback_link, auth_app_fallback_link])
      end
    end

    def update_phone_link
      return unless unconfirmed_phone

      link = view.link_to(t('forms.two_factor.try_again'), reenter_phone_number_path)
      t('instructions.mfa.wrong_number_html', link: link)
    end

    def phone_fallback_link
      t(fallback_instructions, link: phone_link_tag)
    end

    def phone_link_tag
      view.link_to(
        t("links.two_factor_authentication.voice"),
        otp_send_path(locale: LinkLocaleResolver.locale, otp_delivery_selection_form:
          { otp_delivery_preference: 'voice' })
      )
    end

    def fallback_instructions
      "instructions.mfa.sms.fallback_html"
    end

    def resend_code_link
      view.link_to(
        t("links.two_factor_authentication.resend_code.sms"),
        otp_send_path(locale: LinkLocaleResolver.locale,
                      otp_delivery_selection_form:
                        { otp_delivery_preference: otp_delivery_preference, resend: true })
      )
    end
  end
end
