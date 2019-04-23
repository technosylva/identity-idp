require 'json'
require 'socket'

require 'redis'

class CronService
  attr_reader :redis
  attr_reader :logger

  # @param [Hash] redis_config Configuration passed to {Redis.new}. Probably
  #   needs a :url and maybe :driver.
  def initialize(redis_config:, logger: nil)
    @redis = Redis.new(redis_config)

    @logger = logger
    @logger ||= default_logger

    # make sure we're connected
    redis.connected?
  end

  # Generate a lock identifier that communicates enough useful information for
  # debugging. We'll log this identifier when acquiring the lock.
  #
  # This identifier includes the hostname, PID, a random UUID, and the time.
  #
  # @return [String]
  #
  def generate_identifier
    {
      host: Socket.gethostname,
      pid: Process.pid,
      rand: SecureRandom.uuid,
      # rubocop:disable Rails/TimeZone -- using a zone with utc is dumb
      time: Time.now.utc,
      # rubocop:enable Rails/TimeZone
    }.to_json
  end

  # Call block if it hasn't run in the last +seconds+.
  #
  # @param [Integer] seconds The minimum number of seconds between runs.
  # @param [String] name A label for the block that will be used as the
  #   key name for the lock recording the last run time.
  #
  # @example Run a job if it hasn't run in the last 5 minutes
  #   run_if_cron_due(name: 'my-5min-job', seconds: 300) do
  #     do_the_thing
  #   end
  #
  def run_if_cron_due(name:, seconds:)
    raise ArgumentError, 'must pass block' unless block_given?

    if acquire_lock(full_label: label_for(name), expiration_seconds: seconds)
      logger.info("Running job for #{name.inspect}")
      yield
    else
      logger.info("Job for #{name.inspect} is not due to be run yet")
      false
    end
  end

  # Get the time remaining until the next run of the given job. This is
  # equivalent to the TTL remaining on the Redis key. The result may be
  # negative if the key does not exist or has no TTL.
  #
  # @param [String] lock_label A label for the job
  # @return [Integer]
  #
  def time_until_next_run(lock_label:)
    label = label_for(lock_label)
    logger.debug("Checking time until next run of #{label.inspect}")
    redis.ttl(label)
  end

  # Get the current holder of the lock for the given job.
  #
  # @param [String] lock_label A label for the job
  # @return [String, nil]
  #
  def get_current_lock_id(lock_label:)
    label = label_for(lock_label)
    logger.debug("Getting any current lock held for #{label.inspect}")
    redis.get(label)
  end

  private

  # Add the custom prefix to the lock label so it doesn't conflict with any
  # other Redis keys.
  def label_for(label)
    'cron-lock:' + label
  end

  def acquire_lock(full_label:, expiration_seconds:)
    logger.info("Attempting to acquire lock on #{full_label.inspect} " \
                "for #{expiration_seconds.inspect} seconds")
    id = generate_identifier
    result = redis.set(full_label, id, ex: expiration_seconds, nx: true)

    if result
      logger.info("Acquired lock, id: #{id}")
    else
      logger.info('Failed to acquire lock')
      logger.info("Lock currently held by: #{redis.get(full_label)}")
    end

    result
  end

  def default_logger
    l = Logger.new(STDERR)
    l.progname = self.class.name
    l
  end
end
