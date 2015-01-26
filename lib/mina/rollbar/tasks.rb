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

# ### rollbar_username
# Sets the Rollbar username of the user who deployed.  Optional.
set_default :rollbar_username, nil

# ### rollbar_local_username
# Sets the name of the user who deployed.  Defaults to `whoami`.  Optional.
set_default :rollbar_local_username, %x[whoami] rescue nil

# ### rollbar_comment
# Sets a deployment comment (what was deployed, etc.).  Optional.
set_default :rollbar_comment, nil

# ### rollbar_notification_debug
# If true, enables verbosity in the notification to help debug issues.  Defaults to false.
set_default :rollbar_notification_debug, false

namespace :rollbar do

  desc 'Notifies Rollbar of your deployment'
  task notify: :environment do

    unless rollbar_access_token
      print_error 'Must set your `:rollbar_access_token` to notify'
      exit
    end

    unless branch? || commit?
      print_error 'Must define either `:branch` or `:commit`'
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

    queue! 'echo "-----> Notifying Rollbar of deployment"'
    queue! %[#{script.join(' ')}]

  end

end
