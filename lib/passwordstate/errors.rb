module Passwordstate
  class PasswordstateError < RuntimeError; end

  class HTTPError < PasswordstateError
    attr_reader :code, :errors

    def initialize(code, errors = [])
      @code = code.to_i
      @errors = errors

      super <<-ERRMSG
Passwordstate responded with an error to the request;
#{errors.map { |err| err['message'] || err['phrase'] }.join(', ')}
ERRMSG
    end
  end
end
