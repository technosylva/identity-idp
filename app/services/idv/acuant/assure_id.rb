module Idv
  module Acuant
    class AssureId
      include Idv::Acuant::Http

      base_uri 'https://services.assureid.net'

      def initialize(cfg = default_cfg)
        @subscription_id = cfg.fetch(:subscription_id)
        @authentication_params = cfg.slice(:username, :password)
      end

      def create_document
        url = '/AssureIDService/Document/Instance'

        options = {
          headers: content_type_json,
          body: image_params,
          basic_auth: @authentication_params,
        }

        post(url, options) { |body| body.gsub('"', '') }
      end

      def post_front_image(instance_id, image)
        post_image(instance_id, image, 0)
      end

      def post_back_image(instance_id, image)
        post_image(instance_id, image, 1)
      end

      def post_image(instance_id, image, side)
        url = "/AssureIDService/Document/#{instance_id}/Image?side=#{side}&light=0"

        options = {
          headers: accept_json,
          body: image,
          basic_auth: @authentication_params,
        }

        post(url, options)
      end

      def get_results(instance_id)
        url = "/AssureIDService/Document/#{instance_id}"

        options = {
          headers: accept_json,
          basic_auth: @authentication_params,
        }

        get(url, options, &JSON.method(:parse))
      end

      private

      def image_params
        {
          AuthenticationSensitivity: 0, # high
          ClassificationMode: 0,
          Device: {
            HasContactlessChipReader: false,
            HasMagneticStripeReader: false,
            SerialNumber: 'xxx',
            Type: {
              Manufacturer: 'xxx',
              Model: 'xxx',
              SensorType: '1' #camera
            }
          },
          ImageCroppingExpectedSize: '1', #Id
          ImageCroppingMode: '3', #always
          ManualDocumentType: nil,
          ProcessMode: 0,
          SubscriptionId: @subscription_id
        }.to_json
      end

      def default_cfg
        {
          subscription_id: env.acuant_assure_id_subscription_id,
          username: env.acuant_assure_id_username,
          password: env.acuant_assure_id_password,
        }
      end
    end
  end
end
