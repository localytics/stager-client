require File.expand_path "stager/version", File.dirname(__FILE__)
require "thor"
require "httparty"
require "configliere"
require "launchy"
require File.expand_path "auth_strategy", File.dirname(__FILE__)

module Stager
  
  class Command < Thor
    
    Dir[File.expand_path("auth_strategies/*.rb", File.dirname(__FILE__))].each {|f| require f}

    no_commands do
      def auth_strategy
        return @auth_strategy if @auth_strategy
        return nil unless Settings['auth_strategy'] && !Settings['auth_strategy'].empty?
        strategy = Stager.const_get(Settings['auth_strategy']).new
        return nil unless strategy.kind_of? Stager::AuthStrategy
        @auth_strategy = strategy.for_cli(self)
      end

      def apply_request_overrides(options)
        options[:verify] = false if Settings.key?('verify_ssl') && Settings['verify_ssl'] == 'false'
        options
      end

      def request_options(image_name, container_name)
        options = {body: {image_name: image_name, container_name: container_name}}
        return options unless auth_strategy 
        auth_strategy.sign_request_options(options)
        apply_request_overrides(options)
      end
       
      def endpoint
        unless Settings['endpoint'] && !Settings['endpoint'].empty?
          raise "No endpoint configured. Run stager configure endpoint=https://your-stager-host" 
        end
        Settings['endpoint']
      end

      def save_settings
        Settings.save!('~/.stager-cli')
      end
    end

    desc 'configure OPTIONS', "Saves configuration options for stager cli to ~/.stager-cli \n" <<
      "eg: stager configure endpoint=https://stager.io auth_strategy=GithubAuthentication"
    def configure(*args)
      args.each do |a| 
        k, v = a.split('=')
        if v && !v.empty?
          Settings[k.to_s] = v
        else
          Settings.delete(k.to_s)
        end
      end
      save_settings
    end

    desc 'show_config', 'Displays current configuration'
    def show_config
      puts Settings.to_yaml
    end

    desc 'launch IMAGE_NAME CONTAINER_NAME', "Launches a container with specified name, using specified image \n" <<
      'Passing in a container name which points to a running container will cause that container to be re-launched'
    def launch(image_name, container_name)
      r = HTTParty.post("#{endpoint}/launch", request_options(image_name, container_name))
      if r.body =~ URI::regexp
        sleep 2
        Launchy.open(r.body)
      else
        puts r.body
      end
    end

    desc 'kill IMAGE_NAME CONTAINER_NAME', 'Kills a container running specified image with specified name'
    def kill(image_name, container_name)
      r = HTTParty.post("#{endpoint}/kill", request_options(image_name, container_name))
      puts r.body
    end

    Settings.read('~/.stager-cli')
  end
end
