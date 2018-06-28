module TwoFactorAuthentication
  class TotpSetupPresenter < SetupPresenter

    def qrcode(otp_secret_key)
      options = {
        issuer: 'Login.gov',
        otp_secret_key: otp_secret_key,
      }
      url = user.provisioning_uri(nil, options)
      qrcode = RQRCode::QRCode.new(url)
      qrcode.as_png(size: 280).to_data_url
    end
  end
end
