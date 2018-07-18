module Idv
  class DocAuth
    class ImageCache
      CACHE = {}
      def self.put(image)
        uuid = SecureRandom.uuid
        CACHE[uuid] = image
        uuid
      end

      def self.get(uuid)
        CACHE[uuid]
      end
    end

    class Result
      attr_reader :status, :message

      def self.success
        new(:success)
      end

      def self.failure(message)
        new(:failure, message)
      end

      def initialize(status, message=nil)
        @status = status
        @message = message
      end

      def success?
        status == :success
      end

      def failure?
        !success?
      end
    end

    attr_reader :session

    # Order matters
    STEPS = {
      front_image: {
        requires: :front_image,
        handler: :handle_front_image
      },
      back_image: {
        requires: :back_image,
        handler: :handle_back_image
      },
      id_verification_failed: {
        requires: :id_verified,
      },
      self_image: {
        requires: :self_image,
        handler: :handle_self_image
      },
      image_verification_failed: {
        requires: :image_verified,
      },
    }.freeze

    def initialize(session)
      @session = session || {}
    end

    def next_step
      # Find the first requirement that is not satisfied
      step, _config = STEPS.detect do |step, config|
        key = config.fetch(:requires)
        !session[key]
      end
      step || :doc_auth_succeeded
    end

    def handle(step, params)
      handler = STEPS.dig(step.to_sym, :handler)
      return send(handler, params.fetch(:image)) if handler
      Result.failure("Unhandled step #{step}")
    end

    def completed?
      next_step == :doc_auth_succeeded
    end

    def handle_front_image(image)
      status, data = create_document
      return Result.failure(data) if status == :error

      @session[:instance_id] = data

      image_content = image.read

      status, data = upload_front_image(image_content)
      return Result.failure(data) if status == :error

      @session[:front_image] = ImageCache.put(image_content)
      Result.success
    end

    def handle_back_image(image)
      image_content = image.read

      status, data = upload_back_image(image_content)
      return Result.failure(data) if status == :error

      @session[:back_image] = ImageCache.put(image_content)

      status, data = verify_document
      return Result.failure(data) if status == :error

      @session[:id_verified] = true
      @session[:id_verification_data] = data
      Result.success
    end

    def handle_self_image(image)
      image_content = image.read

      status, data = verify_image(image_content)
      return Result.failure(data) if status == :error

      @session[:self_image] = ImageCache.put(image_content)
      @session[:image_verified] = true
      @session[:image_verification_data] = data
      Result.success
    end

    def create_document
      assure_id.create_document
    end

    def upload_front_image(image)
      assure_id.post_front_image(@session[:instance_id], image)
    end

    def upload_back_image(image)
      assure_id.post_back_image(@session[:instance_id], image)
    end

    def verify_document
      assure_id.get_results(@session[:instance_id])
    end

    # Obviously not ideal
    def verify_image(self_image)
      Tempfile.open('foo', encoding: 'ascii-8bit') do |f1|
        Tempfile.open('foo', encoding: 'ascii-8bit') do |f2|
          f1.write(ImageCache.get(@session[:front_image]))
          f1.write(self_image)
          facial_match.verify_image(f1, f2)
        end
      end
    end

    def assure_id
      @assure_id ||= Idv::Acuant::AssureId.new
    end

    def facial_match
      @facial_match ||= Idv::Acuant::FacialMatch.new
    end
  end
end
