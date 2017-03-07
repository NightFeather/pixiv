module Pixiv
  class Client
    module APIWrapper

      SEARCH_DEFAULT_OPT = {
        search_target: "partial_match_for_tags",
        sort: "date_desc",
        duration: "within_last_day"
      }

      def get_recommended_users
        resp = get '/v1/user/recommended'
        resp["user_previews"]
      end

      def get_user id
        get '/v1/user/detail', user_id: id
      end

      def get_user_illusts id, type = "illust"
        resp = get '/v1/user/illusts', { user_id: id, type: type }
        resp["illusts"].map { |il| Pixiv::Illust.new(il) }
      end

      def get_illust id
        resp = get '/v1/illust/detail', illust_id: id
        resp = resp["illust"]
        resp["metadata"] = get_ugoira_metadata id if resp["type"] == 'ugoira'
        Pixiv::Illust.new resp
      end

      def get_ugoira_metadata id
        resp = get '/v1/ugoira/metadata', illust_id: id
        resp["ugoira_metadata"]
      end

      # 搜索 (Search) (无需登录)
      # search_target - 搜索类型
      #   partial_match_for_tags  - 标签部分一致
      #   exact_match_for_tags    - 标签完全一致
      #   title_and_caption       - 标题说明文
      # sort: [date_desc, date_asc]
      # duration: [within_last_day, within_last_week, within_last_month]

      def search keyword, opts = {}
        get '/v1/search/illust', {
          word: keyword
        }.merge(SEARCH_DEFAULT_OPT).merge(opts)
      end

      def fetch_updates restrict = "all"
        resp = get '/v2/illust/follow', restrict: restrict
        resp['illusts']
      end
    end
  end
end
