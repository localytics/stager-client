module Stager
  class AuthStrategy
    
    def for_cli(cli)
      @cli = cli
      self
    end

    def sign_request_options(options)
      raise NotImplementedError
    end
  end
end
