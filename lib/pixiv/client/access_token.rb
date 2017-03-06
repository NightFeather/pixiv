require 'securerandom'

module Pixiv
  class Client

    class AccessToken
      CLIENT_ID  = "BVO2E8vAAikgUBW8FYpi6amXOjQj".freeze
      CLIENT_SECRET = "LI1WsFUDrrquaINOdarrJclCrkTtc3eojCOswlog".freeze
      OAUTH_ENDPOINT = "https://oauth.secure.pixiv.net/auth/token".freeze

      def initialize user, pass, device_token = nil
        @device_token = device_token || SecureRandom.hex(16)
        @expire = Time.now
        @user, @pass = user, pass
        refresh
      end

      def expired?; Time.now < @expire end

      def refresh
        login @user, @pass
        self
      end

      def sign req
        refresh if expired?
        req.add_field "Authorization", "Bearer %s" % [ @access_token ]
        return true
      end

      def login user, pass
        resp = Net::HTTP.post_form URI(OAUTH_ENDPOINT),
                                   client_id:     CLIENT_ID,
                                   client_secret: CLIENT_SECRET,
                                   grant_type:    "password",
                                   username:      user,
                                   password:      pass,
                                   device_token:  @device_token,
                                   get_secure_url: true
  
        raise AuthorizationFailed, resp.body unless %w{ 200 301 302 }.include? resp.code
  
        resp = JSON.parse(resp.body)
        @expire = Time.now + resp["response"]["expires_in"].to_i
        @access_token = resp["response"]["access_token"]
      end

      def to_s
        base = "#<Pixiv::Client::AccessToken:%014x %s>"
        parts = [ object_id << 1 ]
        parts << instance_variables.map { |var|
          next nil if var == :@pass
          val = instance_variable_get(var)
          "%s=%s" % [ var, val.inspect ]
        }.compact.join(", ")
        return base % parts
      end

      def inspect
        to_s
      end

      AuthorizationError = Class.new(ClientError)
      AuthorizationFailed = Class.new(AuthorizationError)
      AuthorizationExpired = Class.new(AuthorizationError)

    end
  end
end
