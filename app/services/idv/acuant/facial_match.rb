module Idv
  module Acuant
    class FacialMatch
      include Idv::Acuant::Http
      # debug_output $stderr
      # default_timeout 60
      base_uri 'https://cssnwebservices.com/CSSNService/CardProcessor'

      def initialize(cfg = default_cfg)
        @license_key = Base64.encode64(cfg.fetch(:license_key))
      end

      def verify_image(id_image, self_image)
        url = '/FacialMatch'

        options = {
          headers: headers,
          body: { idFaceImage: id_image, selfieImage: self_image },
        }

        post(url, options, &JSON.method(:parse))
      end

      private

      def default_cfg
        { license_key: env.acuant_facial_match_license_key }
      end

      def headers
        accept_json.merge(content_type_stream).merge(license_key_auth)
      end

      def license_key_auth
        { 'Authorization' => "LicenseKey #{@license_key}" }
      end
    end
  end
end
