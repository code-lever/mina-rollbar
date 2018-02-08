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

require 'net/http'
require 'rubygems'
require 'json'

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

# ### :rollbar_env
# Sets the rollbar environment being deployed.  If left un-set, will default to `rails_env` value.
set :rollbar_env, nil

namespace :rollbar do

  desc 'Notifies Rollbar of your deployment'
  task :notify do

    unless fetch(:rollbar_access_token)
      print_error 'Rollbar: You must set `:rollbar_access_token` to notify'
      next
    end

    unless set?(:branch) || set?(:commit)
      print_error 'Rollbar: Must set either `:branch` or `:commit`'
      next
    end

    uri      = URI.parse 'https://api.rollbar.com/api/1/deploy/'
    revision = fetch(:commit) || %x[git rev-parse origin/#{fetch(:branch)}].strip
    params   = {
      local_username:   fetch(:rollbar_local_username),
      rollbar_username: fetch(:rollbar_username),
      access_token:     fetch(:rollbar_access_token),
      environment:      fetch(:rollbar_env) || fetch(:rollbar_environment) || fetch(:rails_env),
      comment:          fetch(:rollbar_comment),
      revision:         revision
    }.reject { |_, value| value.nil? }

    request      = Net::HTTP::Post.new(uri.request_uri)
    request.body = ::JSON.dump(params)

    begin
      comment "Notifying Rollbar of deployment"

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        response = http.request(request)

        unless response.is_a?(Net::HTTPSuccess)
          print_error "Rollbar: [#{response.code}] #{response.message}"
        end
      end

    rescue StandardError => e
      print_error "Rollbar: #{e.class} #{e.message}"
    end
  end

end