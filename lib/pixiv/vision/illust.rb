
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
        eyecatch_el = @dom.css(".am__header ._article-illust-eyecatch")[0]
        info = eyecatch_el.css(".aie__info")[0]
        user_link = info.css(".aie__user-name .inner-link")[0].attr('href')
        @eyecatch = {
          id: info.css(".aie__title .inner-link")[0].attr('data-gtm-label'),
          link: info.css(".aie__title .inner-link")[0].attr('href'),
          img: eyecatch_el.css(".inner-link img")[0].attr('src'),
          title: info.css(".aie__title")[0].text.strip,
          user: {
            id:   user_link.match(/id=(\d+)/)[1],
            name: info.css(".aie__user-name .inner-link")[0].text.strip,
            link: user_link
          }
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
