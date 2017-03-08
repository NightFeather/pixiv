require 'time' # for Time.xmlschema
module Pixiv
  module Illust
    class Base

      attr_reader :id, :title, :caption, :thumbnail,
                  :user,
                  :tags, :tools,
                  :create_date, :width, :height,
                  :rate,
                  :view_count, :bookmark_count, :comment_count
=begin
v "id"
v "title"
  "type"                        // not used
v "image_urls"                  => :thumbnail
v "caption"
  "restrict"                    // not used
  "user"                        // wrap as `User`
v "tags"                        // string array
v "tools"
v "create_date"
  "page_count"                  // manipulated by subclasses
v "width"
v "height"
v "sanity_level"
  "meta_single_page"            // manipulated by subclasses
  "meta_pages"                  // manipulated by subclasses
v "total_view"                  => :view_count
v "total_bookmarks"             => :bookmark_count
v "is_bookmarked"
v "visible"                     => @is_visible
v "is_muted"
v "total_comments"              => :comment_count
=end


      def initialize obj
        extract obj.dup
      end

      def muted?; @is_muted; end
      def bookmarked?; @is_bookmarked; end
      def visible?; @is_visible; end

      private
      def extract obj
        @id               = obj["id"]
        @title            = obj["title"]
        @caption          = obj["caption"]
        @thumbnail        = obj["image_urls"]
        @tags             = obj["tags"].map { |o| o["name"] }
        @tools            = obj["tools"]
        @create_date      = Time.xmlschema obj["create_date"]
        @width            = obj["width"]
        @height           = obj["height"]
        @rate             = case obj["sanity_level"]
                            when 1..2
                              :safe
                            when 3..4
                              :questionable
                            when 5..6
                              @tags.include?("R-18G") ?  :explict_grotesque : :explict
                            end
        @view_count       = obj["total_view"]
        @bookmark_count   = obj["total_bookmarks"]
        @comment_count    = obj["total_comments"]

        @is_bookmarked    = obj["is_bookmarked"]
        @is_muted         = obj["is_muted"]
        @is_visible       = obj["visible"]

        @user             = Pixiv::User.new obj["user"]
      end

    end
  end
end
