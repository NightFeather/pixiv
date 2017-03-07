module Pixiv
  module Illust
    class Manga < Base
      attr_reader :page_count, :images
      def extract obj
        super
        @page_count = obj["page_count"]
        @images = Hash[obj["meta_pages"].each_with_index.map { |page, idx| [idx, page["image_urls"]["original"]] }]
      end
    end
  end
end
