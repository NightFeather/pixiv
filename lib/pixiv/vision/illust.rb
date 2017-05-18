
module Pixiv
  module Vision
    class Illust < Base

      attr_reader :eyecatch, :illusts

      def parse
        super
        @eyecatch = {}
        @illusts  = []

        extract_eyecatch
        extract_illusts
      end

      def extract_eyecatch
        eyecatch_el = @dom.css(".am__eyecatch-container")[0]
        link = eyecatch_el.css('.inner-link')[0].attr('href')
        id = link.match(/illust_id=(\d+)/)[1]
        img = eyecatch_el.css('._article-illust-eyecatch')[0].attr('style').match(/url\(\'(.+?)\'\)/)[1]

        @eyecatch = {
          id: id,
          link: link,
          img: img
        }
      end

      def extract_illusts
        works = @dom.css(".am__body > .am__work")
        works.each do |el|
          info = el.css(".am__work__info")
          link = info.css(".am__work__title .inner-link")[0].attr('href')
          user_link = info.css(".am__work__user-name .inner-link")[0].attr('href')

          res = {
            id: link.match(/illust_id=(\d+)/)[1],
            link: link,
            img: el.css(".inner-link img")[1].attr('src'),
            title: info.css(".am__work__title")[0].text.strip,
            user: {
              id:   user_link.match(/id=(\d+)/)[1],
              name: info.css(".am__work__user-name .inner-link")[0].text.strip,
              link: user_link
            }
          }
          @illusts << res
        end
      end

    end
  end
end
