# Stager cli

This gem installs a command line interface for working with a [Stager](https://github.com/localytics/stager) instance.

## Installation

```bash
git clone git@github.com:localytics/stager-cli.git
cd stager-cli
bundle install
rake install
cd pkg
sudo gem install stager-0.0.1.gem
```

## Usage

```bash
#display list of available commands
stager

#minimal config
stager configure endpoint=https://your-stager-instance.com/ auth_strategy=Basic #or Github, depends on Stager instance config
```

## Adding Auth Strategies

When [adding authentication strategies to Stager](https://github.com/localytics/stager/tree/master/request_handlers#authentication_strategy) it is often useful to add a corresponding auth strategy to the Stager cli gem. This allows you to set the auth_strategy using the stager configure command, and have all requests to Stager automatically amended to include the necessary authentication info.

Adding an auth_strategy is very simple, define a class which inherits from Stager::AuthStrategy in the auth_strategies folder, inside the Stager module namespace, and implement the sign_request_options method.

The class will have access to the current Command instance via the @cli instance variable, and the sign_request_options method will receive one argument, the options hash which is passed to the [HTTParty.post](http://www.ruby-doc.org/gems/docs/h/httparty2-0.7.10/HTTParty/ClassMethods.html#method-i-post) call made to a Stager route.

Here's an example auth_strategy that will add foo=bar to the posted params on any call to Stager made using the cli:

```ruby
module Stager
  class Foobar << AuthStrategy
  
    def sign_request_options(options)
      options[:body][:foo] = bar
    end
  end
end
```

After saving the above in auth_strategies, and reinstalling the gem, the following is now possible:

```bash
stager configure auth_strategy=Foobar
stager launch name_of_image name_of_container #post params automatically include foo=bar
```

The gem uses [Configliere](https://github.com/infochimps-labs/configliere) for loading and saving settings from and to local config. The @cli instance variable exposes a save_settings method which persists the current state of the Settings hash to the local config file.

See the [Github](lib/auth_strategies/github.rb) auth strategy for an example of persisting settings to local config and using them in subsequent calls.
