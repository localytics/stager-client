require 'io/console'
module Stager
  class Basic < Stager::AuthStrategy

    def saved_user
      Settings[:username]
    end

    def user_saved?
      saved_user && !saved_user.empty?
    end

    def save_user
      puts "No user configured for basic auth"
      print "Please enter username: "
      username = STDIN.gets.chomp
      puts "\n Saving username to config"
      Settings[:username] = username
      @cli.save_settings
    end

    def sign_request_options(options)
      save_user unless user_saved?
      print "Please enter password for user #{saved_user}: "
      password = STDIN.noecho { |i| i.gets.chomp }
      print "\n"
      options[:basic_auth] = {username: saved_user, password: password}
    end
  end
end
