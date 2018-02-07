# Mina::Rollbar [![Build Status](https://travis-ci.org/code-lever/mina-rollbar.png)](https://travis-ci.org/code-lever/mina-rollbar) [![Dependency Status](https://gemnasium.com/code-lever/mina-rollbar.png)](https://gemnasium.com/code-lever/mina-rollbar) [![Code Climate](https://codeclimate.com/github/code-lever/mina-rollbar.png)](https://codeclimate.com/github/code-lever/mina-rollbar)

[Mina](https://github.com/mina-deploy/mina) tasks for interacting with [Rollbar](http://rollbar.com).

Adds the following tasks:

    rollbar:notify

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mina-rollbar', require: false
```

And then execute:

    $ bundle

## Usage

    require 'mina/rollbar'

    ...
    # replace value w/your real access token
    set :rollbar_access_token, '9a18d718214b4348822b7cec493f86d2'

    task deploy: :environment do
      deploy do
        ...

        to :launch do
          ...
          invoke :'rollbar:notify'
        end
      end
    end

## Options

| Name                         | Description                                            |
| ---------------------------- | ------------------------------------------------------ |
| `rollbar_access_token`       | Rollbar access token (post_server_item token)          |
| `rollbar_username`           | Rollbar username of deploying user (optional)          |
| `rollbar_local_username`     | Local username of deploying user (optional)            |
| `rollbar_comment`            | Comment for this deployment (optional)                 |
| `rollbar_env`                | Deployment environment string, defaults to `rails_env` |

## Contributing

1. Fork it ( https://github.com/code-lever/mina-rollbar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
