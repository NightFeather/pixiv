require 'nokogiri'

module Pixiv
  module Vision
    class Base
  
      attr_reader :type, :title, :caption, :date
  
      def initialize page_id, lang, dom = nil
        @page_id = page_id.to_i
        @lang = lang
        @dom = dom
        parse
      end
  
      def parse
        header = @dom.css(".am__header")[0]
        @type = header.css("._category-label")[0].text.strip
        @title = header.css(".am__title")[0].text.strip
        @caption = header.css(".am__description > p")[0].text.strip
        @date = header.css("._date")[0].text.strip
      end
  
    end
  end
end
