require "launchy"

module Stager
  class Github < Stager::AuthStrategy
    
    def token
      return Settings['github_token'] if Settings['github_token'] and !Settings['github_token'].empty?
      gh_state = Digest::MD5.hexdigest("#{(36**8).to_s(36)}#{Time.now.to_i}")
      oauth_url = HTTParty.post("#{@cli.endpoint}/event_receiver", 
        body: {action: 'get_oauth_url', gh_state: gh_state}).body
      puts "No oauth token configured, please log into Github when prompted. Press ENTER to continue."
      STDIN.gets
      Launchy.open(oauth_url)
      puts "Press ENTER to continue once web authentication flow is complete"
      STDIN.gets
      Settings['github_token'] = 
        HTTParty.post("#{@cli.endpoint}/event_receiver", 
          body: {action: 'get_github_token', gh_state: gh_state}).body
      @cli.save_settings
      Settings['github_token']
    end

    def sign_request_options(options)
      options[:body][:github_token] = token 
    end
  end
end
