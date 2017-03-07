module Pixiv
  Error = Class.new(StandardError)
end

require "pixiv/version"
require 'pixiv/user'
require 'pixiv/illust'
require 'pixiv/client'
