require 'pixiv/downloader/task'
require 'pixiv/string_template'

module Pixiv
  module Illust
    class Manga < Base
      attr_reader :page_count, :images

      def download_meta template = '?user? - ?title?/?idx?'
        ctr = Pixiv::Downloader::Task.new []
        @images.each_pair do |idx, image|
          filename = Pixiv::StringTemplate.convert template, self, idx: idx.to_s.rjust(2,'0')
          filename += File.extname image
          ctr.filelist << { src: image, dest: filename }
        end
        return ctr
      end

      def extract obj
        super
        @page_count = obj["page_count"]
        @images = Hash[obj["meta_pages"].each_with_index.map { |page, idx| [idx, page["image_urls"]["original"]] }]
      end
    end
  end
end
