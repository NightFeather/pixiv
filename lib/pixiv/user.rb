module Pixiv
  class User

    attr_reader :id, :name, :account, :avatar

    def initialize obj
      @id           = obj["id"]
      @name         = obj["name"]
      @account      = obj["account"]
      @avatar       = obj["profile_image_urls"]
      @is_followed  = obj["is_followed"]
    end

    def followed?; @is_followed; end

    def to_s; @name; end
    
    def inspect; super; end
  end
end