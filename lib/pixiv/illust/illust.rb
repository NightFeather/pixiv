require 'pixiv/string_template'
require 'pixiv/downloader/task'

module Pixiv
  module Illust
    class Illust < Base
      attr_reader :original

      def download_meta template = '?user? - ?title?'
        filename = Pixiv::StringTemplate.convert template, self
        filename += File.extname @original
        return Pixiv::Downloader::Task.new src: @original, dest: filename
      end

      def extract obj
        super obj
        @original = obj["meta_single_page"]["original_image_url"]
      end
    end
  end
end
