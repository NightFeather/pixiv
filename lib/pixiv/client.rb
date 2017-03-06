require 'net/https'
require 'securerandom'
require 'json'
require 'pixiv/client/exceptions'
require 'pixiv/client/access_token'
require 'pixiv/client/api_wrapper'

# Making General Operation
# Authorization related ripped to access_token
module Pixiv
  class Client

    include APIWrapper

    API_ENDPOINT = "https://app-api.pixiv.net/".freeze

    def initialize user, pass, opts = {}
      @access_token = AccessToken.new user, pass
    end

    def make_request type, uri, params = {}, header = {}

      uri = URI(URI.join(API_ENDPOINT, uri)) if uri =~ /^\//

      case type
      when /get/i
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Get.new uri, header
      when /post/i
        req = Net::HTTP::Post.new uri, header
        req.form_data = params
      end

      @access_token.sign req
      resp = nil
      Net::HTTP.start(URI(API_ENDPOINT).hostname, use_ssl: true) do |http|
        resp = http.request req
      end

      unless resp.is_a? Net::HTTPOK
        raise RequestError.new(resp), "unexpected response code `#{resp.code}`, expect `200`"
      end

      JSON.parse resp.body
    end

    def get uri, params = {}, header = {}
      make_request :get, uri, params, header
    end

    def post uri, params = {}, header = {}
      make_request :post, uri, params, header
    end

    def download uri
    end
  end
end
