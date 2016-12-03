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
set :rollbar_access_token, nil

# ### rollbar_username
# Sets the Rollbar username of the user who deployed.  Optional.
set :rollbar_username, nil

# ### rollbar_local_username
# Sets the name of the user who deployed.  Defaults to `whoami`.  Optional.
set :rollbar_local_username, %x[whoami].strip rescue nil

# ### rollbar_comment
# Sets a deployment comment (what was deployed, etc.).  Optional.
set :rollbar_comment, nil

# ### rollbar_notification_debug
# If true, enables verbosity in the notification to help debug issues.  Defaults to false.
set :rollbar_notification_debug, false

# ### :rollbar_environment
# Sets the rollbar environment being deployed.  If left un-set, will default to `rails_env` value.
set :rollbar_environment, nil

namespace :rollbar do

  desc 'Notifies Rollbar of your deployment'
  task notify: :environment do

    unless fetch(:rollbar_access_token)
      print_error 'Must set your `:rollbar_access_token` to notify'
      exit
    end

    unless set?(:branch) || set?(:commit)
      print_error 'Must define either `:branch` or `:commit`'
      exit
    end

    revision = set?(:commit) ? fetch(:commit) : %x[git rev-parse #{fetch(:branch)}].strip

    silent = fetch(:rollbar_notification_debug) ? '-v' : '-s -o /dev/null'
    script = ["curl #{silent} https://api.rollbar.com/api/1/deploy/"]
    script << "-F access_token=#{fetch(:rollbar_access_token)}"
    if set?(:rollbar_environment)
      script << "-F environment=#{fetch(:rollbar_environment)}"
    else
      script << "-F environment=#{fetch(:rails_env)}"
    end
    script << "-F revision=#{revision}"
    script << "-F local_username=#{fetch(:rollbar_local_username)}" if set?(:rollbar_local_username)
    script << "-F rollbar_username=#{fetch(:rollbar_username)}" if set?(:rollbar_username)
    script << "-F comment=#{set(:rollbar_comment)}" if set?(:rollbar_comment)

    comment %{Notifying Rollbar of deployment}
    command %[#{script.join(' ')}]

  end

end
