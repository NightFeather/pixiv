module Pixiv
  module Illust
    class Ugoira < Base
      attr_reader :cover, :metadata, :zip_url
      def extract obj
        super
        @cover    = obj["meta_single_page"]["original_image_url"]
        @metadata = obj["metadata"]

        zip_urls = @metadata["zip_urls"]
        @zip_url = %w{original large medium}.each_with_object([]){ |l, o|
          o << zip_urls[l] if zip_urls[l]
        }.first
      end
    end
  end
end
