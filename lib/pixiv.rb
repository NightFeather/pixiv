module Pixiv
  Error = Class.new(StandardError)
end

require "pixiv/version"
require 'pixiv/constants'
require 'pixiv/user'
require 'pixiv/illust'
require 'pixiv/client'
require 'pixiv/string_template'
require 'pixiv/downloader'
require 'pixiv/ugoira_composer'
require 'pixiv/vision'
