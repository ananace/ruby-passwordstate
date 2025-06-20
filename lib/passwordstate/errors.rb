# frozen_string_literal: true

module Passwordstate
  class PasswordstateError < RuntimeError; end

  class NotAcceptableError < PasswordstateError; end

  class HTTPError < PasswordstateError
    attr_reader :code, :request, :response, :errors

    def initialize(code, request, response, errors = [])
      @code = code.to_i
      @request = request
      @response = response

      if errors.count == 1 && errors.first.is_a?(Hash) && errors.first.key?('errors')
        errors = errors.first['errors']
      end
      @errors = errors

      errorstr = errors.map { |err| err['message'] || err['phrase'] || err['error'] }.join('; ')
      super("Passwordstate responded with an error to the request:\n#{errorstr}")
    end

    def self.new_by_code(code, req, res, errors = [])
      code_i = code.to_i

      errtype = nil
      errtype ||= UnauthorizedError if code_i == 401
      errtype ||= ForbiddenError if code_i == 403
      errtype ||= NotFoundError if code_i == 404
      errtype ||= ClientError if code_i >= 400 && code_i < 500
      errtype ||= ServerError if code_i >= 500 && code_i < 600

      if code_i == 302 && res['location'].start_with?('/error/generalerror.aspx?')
        errtype ||= ServerError
        errors = [{ 'phrase' => 'Response code 302, most likely meaning an authorization error' }]
      end

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

  # 401
  class UnauthorizedError < ClientError
  end

  # 403
  class ForbiddenError < ClientError
  end

  # 404
  class NotFoundError < ClientError
  end

  # 5xx
  class ServerError < HTTPError
    def initialize(code, req, res, errors = [])
      super
    end
  end
end
