module Baboon
  class Exception < StandardError
    attr_reader :response

    def initialize response
      @response = response
      super
    end
  end
end