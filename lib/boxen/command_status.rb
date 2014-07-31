module Boxen
  class CommandStatus
    attr_reader :code, :successful_on

    def initialize(code, successful_on = [0])
      @successful_on = successful_on
      @code = code
    end

    def success?
      successful_on.member? code
    end

  end
end
