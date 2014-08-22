# # Modules: Rollbar
# Adds settings and tasks for notifying Rollbar.
#
#     require 'mina/rollbar'
#
# ## Usage example
#     require 'mina_sidekiq/tasks'
#
#     # this is your 'post_server_item' token for your project
#     set :rollbar_access_token, 'rollbar-access-token-goes-here'
#
#     task :deploy do
#       deploy do
#         ...
#
#         to :launch do
#           ...
#           invoke :'rollbar:notify'
#         end
#       end
#     end

require 'mina/rails'

# ## Settings
# Any and all of these settings can be overriden in your `deploy.rb`.

# ### rollbar_access_token
# Sets the access token for your Rollbar account.  Required.
set_default :rollbar_access_token, nil

set_default :rollbar_username, nil

set_default :rollbar_local_username, nil

set_default :rollbar_comment, nil

set_default :rollbar_notification_debug, false

namespace :rollbar do

  desc 'Notifies Rollbar.io of your deployment'
  task notify: :environment do

    unless rollbar_access_token
      error 'Must set your `:rollbar_access_token` to notify'
      exit
    end

    unless branch? || commit?
      error 'Must define either `:branch` or `:commit`'
      exit
    end

    revision = commit? ? commit : %x[git rev-parse #{branch}].strip

    silent = rollbar_notification_debug ? '' : '-s -o /dev/null'
    script = ["curl #{silent} https://api.rollbar.com/api/1/deploy/"]
    script << "-F access_token=#{rollbar_access_token}"
    script << "-F environment=#{rails_env}"
    script << "-F revision=#{revision}"
    script << "-F local_username=#{rollbar_local_username}" if rollbar_local_username
    script << "-F rollbar_username=#{rollbar_username}" if rollbar_username
    script << "-F comment=#{rollbar_comment}" if rollbar_comment

    queue! 'echo "-----> Notifying Rollbar.io of deployment"'
    queue! %[#{script.join(' ')}]

  end

end
