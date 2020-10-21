require 'securerandom'
require 'time'
require 'openssl'

module Pixiv
  class Client

    class AccessToken
      CLIENT_ID  = "MOBrBDS8blbauoSck0ZfDbtuzpyT".freeze
      CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj".freeze
      OTP_KEY = '28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c'.freeze
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

      def generate_otp
        timestamp = Time.now.iso8601
        hashtoken = OpenSSL::Digest::MD5.hexdigest timestamp+OTP_KEY
        return [timestamp, hashtoken]
      end

      def sign req
        refresh if expired?
        req.add_field "Authorization", "Bearer %s" % [ @access_token ]
        return true
      end

      def login user, pass
        uri = URI(OAUTH_ENDPOINT)
        otp_ts, otp_hash = generate_otp
        req = Net::HTTP::Post.new uri, {
          'User-Agent': 'PixivAndroidApp/5.0.115 (Android 6.0; PixivBot)',
          'X-Client-Time': otp_ts,
          'X-Client-Hash': otp_hash
        }
        req.form_data = {
          client_id:     CLIENT_ID,
          client_secret: CLIENT_SECRET,
          grant_type:    "password",
          username:      user,
          password:      pass,
          device_token:  @device_token,
          get_secure_url: true
        }

        Net::HTTP.start uri.host, uri.port, use_ssl: uri.port == 443 do |http|

          httpresp = http.request req
          raise AuthorizationFailed, httpresp.body unless %w{ 200 301 302 }.include? httpresp.code
  
          resp = JSON.parse(httpresp.body)
          @expire = Time.now + resp["response"]["expires_in"].to_i
          @access_token = resp["response"]["access_token"]
        end
        @access_token
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
