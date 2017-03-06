module Pixiv
  ClientError = Class.new(Error)
  class RequestError < ClientError
    attr_reader :response
    def initialize response
      @response = response
    end
  end
end
