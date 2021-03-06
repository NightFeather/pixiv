require 'nokogiri'
require 'pixiv/vision/base'
require 'pixiv/vision/illust'

module Pixiv
  module Vision

    BASEURL = 'https://www.pixivision.net/%s/a/%d'

    def self.new page_id, lang='ja'
      uri = URI(BASEURL % [ lang, page_id.to_i ])

      resp = nil
      http_handle = Net::HTTP.new uri.host, uri.port
      http_handle.set_debug_output STDOUT
      http_handle.use_ssl = true
      http_handle.start do |http|
        resp = http.get uri, 'Accept-Language': lang
      end

      return nil if resp.is_a?(Net::HTTPClientError) or resp.is_a?(Net::HTTPServerError)

      dom = Nokogiri.parse resp.body
      type = dom.css('.am__header .am__sub-info a')[0].attr('data-gtm-label')

      return case type
      when 'illustration'
        Pixiv::Vision::Illust.new page_id, lang, dom
      else
        Pixiv::Vision::Base.new page_id, lang, dom
      end
    end
  end
end
