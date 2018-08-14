module Passwordstate
  class PasswordstateError < RuntimeError; end

  class HTTPError < PasswordstateError
    attr_reader :code, :request, :response, :errors

    def initialize(code, request, response, errors = [])
      @code = code.to_i
      @request = request
      @response = response
      @errors = errors

      super <<-ERRMSG
Passwordstate responded with an error to the request;
#{errors.map { |err| err['message'] || err['phrase'] }.join(', ')}
ERRMSG
    end

    def self.new_by_code(code, req, res, errors = [])
      code_i = code.to_i

      errtype = nil
      errtype ||= NotFoundError if code_i == 404
      errtype ||= ClientError if code_i >= 400 && code_i < 500
      errtype ||= ServerError if code_i >= 500 && code_i < 600

      errtype ||= HTTPError
      errtype.new(code_i, req, res, errors)
    end
  end

  # 4xx
  class ClientError < HTTPError
    def initialize(code, req, res, errors = [])
      super
    end
  end

  # 404
  class NotFoundError < ClientError
    def initialize(code, req, res, errors = [])
      super
    end
  end

  # 5xx
  class ServerError < HTTPError
    def initialize(code, req, res, errors = [])
      super
    end
  end
end
