module Pixiv
  module Constants
    module Search
      module Match
        TagsPartial = 'partial_match_for_tags'
        TagsExact = 'exact_match_for_tags'
        TitleAndCaption = 'title_and_caption'
      end
      module Sort
        DSC = 'date_desc'
        ASC = 'date_asc'
      end
      module Duration
        LastDay = 'within_last_day'
        LastWeek = 'within_last_week'
        LastMonth = 'within_last_month'
      end
    end
  end

  include Constants
end
