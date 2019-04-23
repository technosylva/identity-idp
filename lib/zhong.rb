require 'zhong'
require 'redis'

Zhong.redis = Redis.new(
  url: Figaro.env.redis_url_cron!,
  driver: :hiredis,
)

Zhong.schedule do
  #category 'GPO mailing' do
  #  every(1.day, 'USPS confirmation daily upload', at: ['00:00']) do
  #    UspsConfirmationUploader.new.run
  #  end
  #end

  #category 'Account deletion' do
  #  # Account deletion request grant emails, runs every 5 minutes
  #  every(5.minutes, 'Deletion request grant emails, every 5 minutes') do
  #    AccountReset::GrantRequestsAndSendEmails.new.call
  #  end
  #end

  #category 'Sample jobs' do
  #  every(30.seconds, 'Print hello') { Rails.logger.warn 'Hello from sample job'; raise 'omg' }

  #  every(60.seconds, 'Long running job') do
  #    Timeout.timeout(10) do
  #      Rails.logger.warn('Starting long running job')
  #      sleep 300
  #      Rails.logger.warn('Finished long running job')
  #    end
  #  end
  #end

  category 'new tests' do
    every(5.minutes, 'Print fizz at 1, 2, 4, 6, 8, 10, 12, 13', at: %w[**:01 **:02 **:04 **:06 **:08 **:10 **:12 **:13], grace: 0) do
      logger.warn('FIZZ')
    end

    every(5.minutes, 'Print omg at 50, 51, 53, 57, 58, 0', at: %w[**:50 **:51 **:53 **:57 **:58 **:00], grace: 0) do
      logger.warn('OMG')
    end

    every(1.minute, 'Print buzz starting at 5:30', at: %w[**:20], grace: 0) do
      logger.warn('buzz')
    end

    every(30.minutes, 'Print every 30 starting at 04', at: %w[**:04], grace: 0)
  end


  error_handler do |e, job|
    puts "dang, #{job} messed up: #{e}"
    puts "new relic notice error would be here" # TODO XXX
  end

end

# Call Zhong.start to run these jobs


