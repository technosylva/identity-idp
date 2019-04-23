require 'zhong'

namespace :zhong do
  desc 'Run all periodic jobs defined in this file'
  task run: :environment do
    # This loops forever and stops when signalled with INT/TERM
    Zhong.start

    ::NewRelic::Agent.shutdown
  end
end
