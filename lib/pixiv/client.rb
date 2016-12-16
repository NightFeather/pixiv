require 'net/https'
require 'securerandom'
require 'json'

module Pixiv
  class Client

    CLIENT_ID  = "BVO2E8vAAikgUBW8FYpi6amXOjQj".freeze
    CLIENT_SECRET = "LI1WsFUDrrquaINOdarrJclCrkTtc3eojCOswlog".freeze
    OAUTH_ENDPOINT = "https://oauth.secure.pixiv.net/auth/token".freeze
    API_ENDPOINT = "https://app-api.pixiv.net/".freeze

    def initialize user, pass, opts = {}
      @username = nil
      @password = nil
      @cache_auth = opts[:cache_auth] || false
      @device_token = SecureRandom.hex(16)
      @access_token = ""
      authorize user, pass
    end

    def authorize user = nil, pass = nil

      user, pass = @username, @password if user.nil? && pass.nil? && !cache_auth?

      D "get token with #{user}:#{pass}"

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

      @access_token = resp["response"]["access_token"]

      @username, @password = user, pass if user && pass && cache_auth?
    end

    def cache_auth?; return @cache_auth; end
    def cache_auth!; @cache_auth = true; end

    def request req
      req["Authorization"] = "Bearer %s" % [ @access_token ]
      http = Net::HTTP.new("app-api.pixiv.net", 443)
      http.use_ssl = true
      resp = http.request req
      p JSON.parse resp.body
    end

    def get uri, params = {}, header = {}
      uri = URI.join(API_ENDPOINT, uri) if uri.is_a? String and uri =~ /^\//
      (uri = URI(uri)).query = URI.encode_www_form(params)
      D uri
      request Net::HTTP::Get.new(uri, header)
    end

    def post uri, params = {}, header = {}
      req = Net::HTTP::Post.new URI(uri), header
      req.form_data = params
      request req
    end

    def download uri
    end

    Error = Class.new(StandardError)
    AuthorizationError = Class.new(Error)
    AuthorizationFailed = Class.new(AuthorizationError)
    AuthorizationExpired = Class.new(AuthorizationError)

  end
end
