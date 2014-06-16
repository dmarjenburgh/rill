require 'appsignal'
require 'appsignal/marker'

namespace :appsignal do
  desc "Send appsignal a deploy signal"
  task :deploy do
    env  = fetch(:rails_env, fetch(:rack_env, 'production'))
    user = ENV['USER'] || ENV['USERNAME']

    logger = fetch(:logger, Logger.new($stdout))
    appsignal_config = Appsignal::Config.new(ENV['PWD'], env, fetch(:appsignal_config, {}), logger)

    if appsignal_config && appsignal_config.active?
      marker_data = {
        :revision   => fetch(:current_revision),
        :user       => user
      }
      marker = Appsignal::Marker.new(marker_data, appsignal_config, logger)
      marker.transmit
    end
  end
end

after 'deploy:finished', 'appsignal:deploy'