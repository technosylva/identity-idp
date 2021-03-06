require 'session_encryptor'
require 'session_encryptor_error_handler'

options = {
  key: '_upaya_session',
  redis: {
    driver: :hiredis,

    # cookie expires with browser close
    expire_after: nil,

    # Redis expires session after N minutes
    ttl: AppConfig.env.session_timeout_in_minutes.to_i.minutes,

    key_prefix: "#{AppConfig.env.domain_name}:session:",
    url: AppConfig.env.redis_url,
  },
  on_session_load_error: SessionEncryptorErrorHandler,
  serializer: SessionEncryptor.new,
}

Rails.application.config.session_store :redis_session_store, options
