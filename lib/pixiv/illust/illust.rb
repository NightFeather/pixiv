module Pixiv
  module Illust
    class Illust < Base
      attr_reader :original

      def extract obj
        super obj
        @original = obj["meta_single_page"]["original_image_url"]
      end
    end
  end
end
