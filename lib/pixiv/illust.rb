require 'pixiv/illust/base'
require 'pixiv/illust/illust'
require 'pixiv/illust/manga'
require 'pixiv/illust/ugoira'

module Pixiv
  module Illust
    def self.new obj
      if obj["type"] == "ugoira"
        Ugoira.new(obj)
      elsif obj["page_count"] > 1
        Manga.new(obj)
      else
        Illust.new(obj)
      end
    end
  end
end
