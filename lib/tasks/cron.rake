require 'cron_service'

namespace :cron do
  desc 'Run all periodic jobs defined in this file'
  task run: :environment do
    redis_config = {
      url: Figaro.env.redis_url_cron!,
      driver: :hiredis,
    }

    c = CronService.new(redis_config: redis_config, logger: Rails.logger)

    # GPO upload for USPS mailing, runs every 24 hours
    c.run_if_cron_due(name: 'usps-confirmation-uploader', seconds: 24 * 3600) do
      UspsConfirmationUploader.new.run
    end

    # Account deletion request grant emails, runs every 5 minutes
    c.run_if_cron_due(name: 'account-deletion-confirmation', seconds: 300) do
      AccountReset::GrantRequestsAndSendEmails.new.call
    end
  end
end
